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
      contentType: file.type || 'image/jpeg',
    })
    if (error) throw new Error(`Помилка завантаження: ${error.message}`)
    const { data } = supabase.storage.from(BUCKET).getPublicUrl(path)
    return `${data.publicUrl}?v=${Date.now()}`
  }

  const moveArtwork = async (exhId: number | string, oldSlot: number, newSlot: number) => {
    if (oldSlot === newSlot) return null
    const from = artworkPath(exhId, oldSlot)
    const to   = artworkPath(exhId, newSlot)
    const { data: dl, error: dlErr } = await supabase.storage.from(BUCKET).download(from)
    if (dlErr) throw new Error(`Не вдалося прочитати файл: ${dlErr.message}`)
    const blob = await dl.blob()
    const { error: upErr } = await supabase.storage.from(BUCKET).upload(to, blob, {
      cacheControl: '60', upsert: true, contentType: blob.type || 'image/jpeg',
    })
    if (upErr) throw new Error(`Не вдалося зберегти файл: ${upErr.message}`)
    await supabase.storage.from(BUCKET).remove([from])
    const { data } = supabase.storage.from(BUCKET).getPublicUrl(to)
    return `${data.publicUrl}?v=${Date.now()}`
  }

  return { uploadArtwork, moveArtwork }
}
