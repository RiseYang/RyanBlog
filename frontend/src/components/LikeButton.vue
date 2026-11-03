<template>
  <button
    type="button"
    class="like-btn"
    :class="[variant, { liked }]"
    :disabled="busy"
    :aria-pressed="liked"
    :aria-label="liked ? `取消喜欢，当前 ${count}` : `喜欢，当前 ${count}`"
    :title="liked ? '取消喜欢' : '喜欢'"
    @click="toggle"
  >
    <svg class="heart" viewBox="0 0 16 16" aria-hidden="true">
      <path
        d="M8 13.6C5.4 11.4 2 8.8 2 5.7 2 3.8 3.4 2.4 5.1 2.4c1.05 0 1.9.55 2.9 1.55C9 2.95 9.85 2.4 10.9 2.4 12.6 2.4 14 3.8 14 5.7c0 3.1-3.4 5.7-6 7.9z"
      />
    </svg>
    <span class="like-count">{{ count }}</span>
  </button>
</template>

<script setup>
import { onMounted, ref, watch } from 'vue'
import { getPageLike, getPostLike, togglePageLike, togglePostLike } from '@/api/like'
import { getClientId } from '@/utils/clientId'

const props = defineProps({
  postId: { type: [Number, String], default: null },
  pageKey: { type: String, default: '' },
  variant: { type: String, default: 'mac' }
})

const count = ref(0)
const liked = ref(false)
const busy = ref(false)

async function load() {
  if (!props.postId && !props.pageKey) return
  try {
    const clientId = getClientId()
    const res = props.postId
      ? await getPostLike(props.postId, clientId)
      : await getPageLike(props.pageKey, clientId)
    count.value = res.data?.count || 0
    liked.value = !!res.data?.liked
  } catch {
    // 保留上次读到的数字，按钮仍可再试
  }
}

async function toggle() {
  if (busy.value || (!props.postId && !props.pageKey)) return
  const previous = { count: count.value, liked: liked.value }
  liked.value = !liked.value
  count.value = Math.max(0, count.value + (liked.value ? 1 : -1))
  busy.value = true
  try {
    const clientId = getClientId()
    const res = props.postId
      ? await togglePostLike(props.postId, clientId)
      : await togglePageLike(props.pageKey, clientId)
    count.value = res.data?.count ?? previous.count
    liked.value = !!res.data?.liked
  } catch {
    count.value = previous.count
    liked.value = previous.liked
  } finally {
    busy.value = false
  }
}

watch(() => [props.postId, props.pageKey], load)
onMounted(load)
</script>

<style scoped>
.like-btn {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  color: #000;
  font-family: Geneva, "Lucida Grande", "PingFang SC", "Microsoft YaHei", sans-serif;
  font-size: 13px;
  line-height: 1;
  cursor: pointer;
}

.like-btn:disabled {
  cursor: default;
}

.heart {
  width: 14px;
  height: 14px;
  display: block;
}

.heart path {
  fill: none;
  stroke: currentColor;
  stroke-width: 1.4;
  stroke-linejoin: round;
}

.liked .heart path {
  fill: currentColor;
}

.like-btn.mac {
  background: #ddd;
  border: 2px solid #000;
  border-color: #fff #000 #000 #fff;
  border-radius: 0;
  padding: 2px 8px;
}

.like-btn.mac:hover:not(:disabled) {
  background: #eee;
}

.like-btn.mac:active:not(:disabled) {
  border-color: #000 #fff #fff #000;
  background: #ccc;
}

.like-btn.mac.liked {
  background: #000;
  color: #fff;
  border-color: #000 #fff #fff #000;
}

.like-btn.sheet {
  margin-top: 10px;
  padding: 3px 8px;
  color: #2e3436;
  background: #fff;
  border: 1px solid #c0bdb8;
  border-radius: 3px;
}

.like-btn.sheet.liked {
  background: #2e3436;
  color: #fff;
  border-color: #2e3436;
}

.like-btn:focus-visible {
  outline: 1px dotted currentColor;
  outline-offset: 2px;
}
</style>
