export function useArtworkUpload() {
  const supabase = useSupabaseClient()
  const BUCKET = 'images'
  const artworkPath = (exhId: number | string, slot: number) =>
    `exhibitions/${exhId}/artwork${slot}.jpg`

  const uploadArtwork = async (exhId: number | string, slot: number, file: File) => {
    if (!file) throw new Error('Файл не вибрано')
    const path = artworkPath(exhId, slot)
    const { error } = await supabase.storage.from(BUCKET).upload(path, file, {
      cacheControl: '60',
      upsert: true,
      contentType: file.type || 'image/jpeg'
    })
    if (error) throw new Error(`Помилка завантаження: ${error.message}`)
    const { data } = supabase.storage.from(BUCKET).getPublicUrl(path)
    return `${data.publicUrl}?v=${Date.now()}`
  }

  return { uploadArtwork }
}
