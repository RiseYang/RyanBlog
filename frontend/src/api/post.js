import request from './request'

export function getPostPage(params) {
  return request.get('/posts', { params })
}

export function getAdminPostPage(params) {
  return request.get('/posts/manage', { params })
}

export function getPostById(id) {
  return request.get(`/posts/${id}`)
}

export function getPostBySlug(slug) {
  return request.get(`/posts/slug/${encodeURIComponent(slug)}`)
}

export function createPost(data) {
  return request.post('/posts', data)
}

export function updatePost(id, data) {
  return request.put(`/posts/${id}`, data)
}

export function deletePost(id) {
  return request.delete(`/posts/${id}`)
}

export function getFeaturedPosts(limit = 5) {
  return request.get('/posts/featured', { params: { limit } })
}

export function getTopPosts(limit = 5) {
  return request.get('/posts/top', { params: { limit } })
}
