export function useExhibitionStorage() {
  const supabase = useSupabaseClient()
  const BUCKET = 'images'
  const removeExhibitionFiles = async (exhId: number | string) => {
    await supabase.storage.from(BUCKET).remove([
      `exhibitions/${exhId}/cover.jpg`,
      `exhibitions/${exhId}/card.jpg`,
    ])
  }
  return { removeExhibitionFiles }
}
