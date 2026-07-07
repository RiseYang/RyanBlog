import request from './request'

export function getCategories() {
  return request.get('/categories')
}

export function getCategoryById(id) {
  return request.get(`/categories/${id}`)
}

export function createCategory(data) {
  return request.post('/categories', data)
}

export function updateCategory(id, data) {
  return request.put(`/categories/${id}`, data)
}

export function deleteCategory(id) {
  return request.delete(`/categories/${id}`)
}

export function getNavCategories() {
  return request.get('/categories/nav')
}
