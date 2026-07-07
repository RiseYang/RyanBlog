export function isSuperAdmin(role) {
  return role === 'super_admin'
}

export function isSubscriber(role) {
  return role === 'subscriber'
}

export function canAccessComments(role) {
  return isSuperAdmin(role)
}

export function canAccessUsers(role) {
  return isSuperAdmin(role)
}

export function canCreatePost(role) {
  return isSuperAdmin(role) || isSubscriber(role)
}

export function canEditPost(role, post, userId) {
  if (isSuperAdmin(role)) return true
  if (!isSubscriber(role)) return false
  return post?.authorId != null && Number(post.authorId) === Number(userId)
}

export function canDeletePost(role) {
  return isSuperAdmin(role)
}

export function canDeleteCategory(role) {
  return isSuperAdmin(role)
}

export function canDeleteTag(role) {
  return isSuperAdmin(role)
}

export function subscriberStatusOptions() {
  return [
    { label: '草稿', value: 'draft' },
    { label: '已发布', value: 'published' }
  ]
}

export function adminStatusOptions() {
  return [
    { label: '草稿', value: 'draft' },
    { label: '已发布', value: 'published' },
    { label: '已归档', value: 'archived' },
    { label: '定时', value: 'scheduled' },
    { label: '私密', value: 'private' }
  ]
}
