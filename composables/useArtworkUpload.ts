export function useArtworkUpload() {
  const supabase = useSupabaseClient()
  const BUCKET = 'images'

  const artworkPath = (exhId: number | string, slot: number) =>
    `exhibitions/${exhId}/artwork${slot}.jpg`

  const uploadArtwork = async (exhId: number | string, slot: number, file: File) => {
    const path = artworkPath(exhId, slot)
    // upsert = true -> перезапише існуюче
    const { error } = await supabase.storage.from(BUCKET).upload(path, file, {
      cacheControl: '60',
      upsert: true,
      contentType: file.type || 'image/jpeg'
    })
    if (error) throw error
    const { data } = supabase.storage.from(BUCKET).getPublicUrl(path)
    // cache-bust
    return `${data.publicUrl}?v=${Date.now()}`
  }

  // "перейменування" = копія на новий шлях + видалення старого
  const moveArtwork = async (exhId: number | string, oldSlot: number, newSlot: number) => {
    if (oldSlot === newSlot) return
    const from = artworkPath(exhId, oldSlot)
    const to   = artworkPath(exhId, newSlot)
    // завантажити як копію
    const { data: dl, error: dlErr } = await supabase.storage.from(BUCKET).download(from)
    if (dlErr) throw dlErr
    const blob = await dl.blob()
    const { error: upErr } = await supabase.storage.from(BUCKET).upload(to, blob, {
      cacheControl: '60', upsert: true, contentType: blob.type || 'image/jpeg'
    })
    if (upErr) throw upErr
    // видалити старий
    await supabase.storage.from(BUCKET).remove([from])
    const { data } = supabase.storage.from(BUCKET).getPublicUrl(to)
    return `${data.publicUrl}?v=${Date.now()}`
  }

  return { uploadArtwork, moveArtwork }
}
