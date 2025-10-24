export default defineNuxtRouteMiddleware(async (to) => {
  if (!to.path.startsWith('/admin')) return
  const user = useSupabaseUser()
  if (!user.value) return navigateTo('/login?next=' + encodeURIComponent(to.path))
  // Simple gate: server will still enforce RLS; here we just fetch profile role
  const client = useSupabaseClient()
  const { data } = await client.from('profiles').select('role').eq('id', user.value.id).maybeSingle()
  if (!data || data.role !== 'admin') return navigateTo('/')
})
