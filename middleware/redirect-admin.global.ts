export default defineNuxtRouteMiddleware(async (to, from) => {
  const user = useSupabaseUser()
  const supabase = useSupabaseClient()
  if (!user.value) return

  // fetch profile to check role (cached by Nuxt)
  const { data, error } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', user.value.id)
    .maybeSingle()

  if (!error && data?.role === 'admin' && from.path === '/login' && to.path === '/') {
    return navigateTo('/admin')
  }
})
