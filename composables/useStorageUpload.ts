export function useStorageUpload() {
  const supabase = useSupabaseClient()
  const BUCKET = 'images'

  const uploadFile = async (file: File, dir = 'uploads') => {
    const ext = file.name.split('.').pop() || 'bin'
    const path = `${dir}/${Date.now()}-${Math.random().toString(36).slice(2)}.${ext}`
    const { data, error } = await supabase.storage.from(BUCKET).upload(path, file, {
      upsert: false,
      contentType: file.type
    })
    if (error) throw error
    const { data: urlData } = supabase.storage.from(BUCKET).getPublicUrl(data.path)
    return urlData.publicUrl
  }

  return { uploadFile }
}
