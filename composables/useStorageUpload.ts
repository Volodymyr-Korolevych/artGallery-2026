export function useStorageUpload() {
  const supabase = useSupabaseClient()
  const BUCKET = 'images'

  const publicUrl = (path: string) => {
    const { data } = supabase.storage.from(BUCKET).getPublicUrl(path)
    return `${data.publicUrl}?v=${Date.now()}`
  }

  const uploadFile = async (path: string, file: File) => {
    const { error } = await supabase.storage.from(BUCKET).upload(path, file, {
      cacheControl: '60',
      upsert: true,
      contentType: file.type || 'image/jpeg'
    })
    if (error) throw new Error(error.message)
    return publicUrl(path)
  }

  // Exhibitions
  const coverPath = (exhId: number|string) => `exhibitions/${exhId}/cover.jpg`
  const cardPath  = (exhId: number|string) => `exhibitions/${exhId}/card.jpg`
  const uploadCoverForExhibition = (exhId: number|string, file: File) =>
    uploadFile(coverPath(exhId), file)
  const uploadCardForExhibition = (exhId: number|string, file: File) =>
    uploadFile(cardPath(exhId), file)

  // Artists
  const artistPortraitPath = (artistId: number|string) => `artists/${artistId}/portrait.jpg`
  const uploadArtistPortrait = (artistId: number|string, file: File) =>
    uploadFile(artistPortraitPath(artistId), file)

  return {
    uploadCoverForExhibition,
    uploadCardForExhibition,
    uploadArtistPortrait
  }
}
