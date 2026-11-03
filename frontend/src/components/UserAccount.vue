<template>
  <div ref="root" class="user-account">
    <button
      type="button"
      class="user-info"
      :class="{ open }"
      :title="userStore.isLoggedIn ? '账号' : '登录'"
      :aria-expanded="userStore.isLoggedIn ? open : undefined"
      :aria-haspopup="userStore.isLoggedIn ? 'menu' : undefined"
      @click="onClick"
    >
      <span class="avatar">
        <img v-if="avatar" :src="avatar" alt="" />
        <span v-else>{{ name.charAt(0) }}</span>
      </span>
      <span class="user-name">{{ name }}</span>
      <span v-if="badge != null && badge !== ''" class="level">{{ badge }}</span>
    </button>
    <div v-if="open" class="account-menu" role="menu">
      <button v-if="userStore.isAdmin" type="button" role="menuitem" @click="goAdmin">进入后台</button>
      <button type="button" role="menuitem" @click="signOut">退出登录</button>
    </div>
  </div>
</template>

<script setup>
import { onMounted, onUnmounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'

defineProps({
  name: { type: String, required: true },
  avatar: { type: String, default: '' },
  badge: { type: [String, Number], default: '' }
})

const router = useRouter()
const userStore = useUserStore()
const root = ref(null)
const open = ref(false)

function onClick() {
  if (!userStore.isLoggedIn) {
    router.push('/login')
    return
  }
  open.value = !open.value
}

function goAdmin() {
  open.value = false
  router.push('/admin')
}

async function signOut() {
  open.value = false
  await userStore.logout()
}

function onPointerDown(event) {
  if (!open.value) return
  if (root.value && !root.value.contains(event.target)) open.value = false
}

function onKeydown(event) {
  if (event.key === 'Escape') open.value = false
}

onMounted(() => {
  document.addEventListener('pointerdown', onPointerDown)
  document.addEventListener('keydown', onKeydown)
})

onUnmounted(() => {
  document.removeEventListener('pointerdown', onPointerDown)
  document.removeEventListener('keydown', onKeydown)
})
</script>

<style scoped>
.user-account {
  position: relative;
  margin-left: auto;
}

.user-info {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  border: none;
  background: transparent;
  border-radius: 0;
  padding: 2px 8px;
  color: #000;
  font-family: inherit;
  font-size: 13px;
  cursor: pointer;
}

.user-info:hover,
.user-info:focus-visible,
.user-info.open {
  background: #000;
  color: #fff;
  outline: none;
}

.avatar {
  width: 16px;
  height: 16px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  border: 1px solid #000;
  border-radius: 0;
  background: #fff;
  color: #000;
  font-size: 10px;
  font-weight: 700;
  flex-shrink: 0;
}

.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.user-name {
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.level {
  font-size: 12px;
}

.account-menu {
  position: absolute;
  top: 100%;
  right: 0;
  z-index: 40;
  min-width: 112px;
  margin-top: 1px;
  padding: 2px;
  background: #ddd;
  border: 1px solid #000;
  box-shadow: 2px 2px 0 #000;
}

.account-menu button {
  display: block;
  width: 100%;
  padding: 4px 10px;
  border: none;
  background: transparent;
  color: #000;
  font-family: inherit;
  font-size: 13px;
  text-align: left;
  cursor: pointer;
}

.account-menu button:hover,
.account-menu button:focus-visible {
  background: #000;
  color: #fff;
  outline: none;
}
</style>
