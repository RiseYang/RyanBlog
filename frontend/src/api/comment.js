import request from './request'

export function getCommentPage(params) {
  return request.get('/comments/manage', { params })
}

export function getCommentsByPost(postId) {
  return request.get(`/comments/post/${postId}`)
}

export function updateCommentStatus(id, status) {
  return request.put(`/comments/${id}/status`, null, { params: { status } })
}

export function deleteComment(id) {
  return request.delete(`/comments/${id}`)
}
