export function useStorageUpload() {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  const BUCKET = 'images'

  const ensureAuth = () => {
    if (!user.value) throw new Error('Потрібно увійти в систему')
  }

  // Deterministic paths
  const uploadCoverForExhibition = async (id: string | number, file: File) => put(`exhibitions/${id}/cover.jpg`, file)
  const uploadCardForExhibition  = async (id: string | number, file: File) => put(`exhibitions/${id}/card.jpg`, file)
  const uploadArtistPortrait     = async (id: string | number, file: File) => put(`artists/${id}/portrait.jpg`, file)
  const uploadArtworkImage       = async (id: string | number, file: File) => put(`artworks/${id}/image.jpg`, file)

  const put = async (path: string, file: File) => {
    ensureAuth()
    // overwrite allowed + set contentType; add short cache for CDN
    const { error } = await supabase.storage
      .from(BUCKET)
      .upload(path, file, { upsert: true, contentType: file.type, cacheControl: '60' })
    if (error) throw error
    // cache-busting query to force refresh in UI
    const { data: pub } = supabase.storage.from(BUCKET).getPublicUrl(path)
    const url = pub.publicUrl + `?v=${Date.now()}`
    return url
  }

  return {
    uploadCoverForExhibition,
    uploadCardForExhibition,
    uploadArtistPortrait,
    uploadArtworkImage
  }
}
