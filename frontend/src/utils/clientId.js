export function getClientId() {
  const key = 'blog-client-id'
  const current = localStorage.getItem(key)
  if (current && /^[A-Za-z0-9_-]{8,64}$/.test(current)) return current
  const created = crypto.randomUUID().replace(/-/g, '')
  localStorage.setItem(key, created)
  return created
}
