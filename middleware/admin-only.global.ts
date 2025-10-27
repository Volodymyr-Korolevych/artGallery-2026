export default defineNuxtRouteMiddleware(async (to) => {
  if (!to.path.startsWith('/admin')) return
  const user = useSupabaseUser()
  const supabase = useSupabaseClient()
  if (!user.value) return navigateTo('/login')
  const { data } = await supabase.from('profiles').select('role').eq('id', user.value.id).maybeSingle()
  if (data?.role !== 'admin') return navigateTo('/')
})
