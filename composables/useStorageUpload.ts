export function useStorageUpload() {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  const BUCKET = 'images'
  const ensureAuth = () => {
    if (!user.value) throw new Error('Потрібно увійти в систему')
  }
  const toSlug = (s:string) =>
    s.toLowerCase().trim().replace(/[^a-zа-яіїє0-9]+/gi,'-').replace(/^-+|-+$/g,'')
  const put = async (path:string, file: File) => {
    ensureAuth()
    const { error } = await supabase.storage.from(BUCKET).upload(path, file, { upsert: true, contentType: file.type })
    if (error) throw error
    const { data: pub } = supabase.storage.from(BUCKET).getPublicUrl(path)
    return pub.publicUrl
  }
  return {
    toSlug,
    uploadCoverForExhibition: (exhIdOrSlug:string|number, file:File) => put(`exhibitions/${exhIdOrSlug}/cover.jpg`, file),
    uploadCardForExhibition:  (exhIdOrSlug:string|number, file:File) => put(`exhibitions/${exhIdOrSlug}/card.jpg`, file),
    uploadArtistPortrait:     (artistId:number|string, file:File)      => put(`artists/${artistId}/portrait.jpg`, file),
    uploadArtworkImage:       (artId:number|string, file:File)         => put(`artworks/${artId}/image.jpg`, file),
  }
}
