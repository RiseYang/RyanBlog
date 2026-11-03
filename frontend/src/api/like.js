import request from './request'

export function getPostLike(postId, clientId) {
  return request.get(`/public/likes/posts/${postId}`, { params: { clientId } })
}

export function togglePostLike(postId, clientId) {
  return request.post(`/public/likes/posts/${postId}`, { clientId })
}

export function getPageLike(pageKey, clientId) {
  return request.get(`/public/likes/pages/${pageKey}`, { params: { clientId } })
}

export function togglePageLike(pageKey, clientId) {
  return request.post(`/public/likes/pages/${pageKey}`, { clientId })
}
