<template>
  <div ref="stage" class="stage" :class="{ leaving }" @pointerdown="push">
    <p class="kicker">Welcome to Ryan's Java World</p>
    <p class="hint">点一个方向</p>
  </div>
</template>

<script setup>
import { onMounted, onUnmounted, ref } from 'vue'

const emit = defineEmits(['done'])

const words = [
  'abstract', 'assert', 'boolean', 'break', 'byte', 'case', 'catch', 'char', 'class', 'const',
  'continue', 'default', 'do', 'double', 'else', 'enum', 'exports', 'extends', 'final', 'finally',
  'float', 'for', 'goto', 'if', 'implements', 'import', 'instanceof', 'int', 'interface', 'long',
  'module', 'native', 'new', 'non-sealed', 'open', 'opens', 'package', 'permits', 'private', 'protected',
  'provides', 'public', 'record', 'requires', 'return', 'sealed', 'short', 'static', 'strictfp', 'super',
  'switch', 'synchronized', 'this', 'throw', 'throws', 'to', 'transient', 'transitive', 'try', 'uses',
  'var', 'void', 'volatile', 'when', 'while', 'with', 'yield'
]
const stage = ref(null)
const leaving = ref(false)

let frame = 0
let finished = false
let rotY = 0.4
let rotX = 0.25
let offsetX = 0
let offsetY = 0
let vx = 0
let vy = 0
let launched = false
const points = []
const nodes = []

function sphere(count) {
  const golden = Math.PI * (3 - Math.sqrt(5))
  for (let i = 0; i < count; i += 1) {
    const y = 1 - (i / (count - 1)) * 2
    const ring = Math.sqrt(1 - y * y)
    const theta = golden * i
    points.push({
      x: Math.cos(theta) * ring,
      y,
      z: Math.sin(theta) * ring,
      text: words[i % words.length],
      hot: i % 5 === 0
    })
  }
}

function project(point, radius) {
  const cosY = Math.cos(rotY)
  const sinY = Math.sin(rotY)
  const cosX = Math.cos(rotX)
  const sinX = Math.sin(rotX)
  const x1 = point.x * cosY + point.z * sinY
  const z1 = -point.x * sinY + point.z * cosY
  const y2 = point.y * cosX - z1 * sinX
  const z2 = point.y * sinX + z1 * cosX
  const depth = 2.6
  const scale = depth / (depth - z2)
  return {
    x: x1 * radius * scale,
    y: y2 * radius * scale,
    scale,
    front: (z2 + 1) / 2
  }
}

function tick() {
  const root = stage.value
  if (!root) return
  const width = root.clientWidth
  const height = root.clientHeight
  const radius = Math.min(width, height) * 0.34
  rotY += 0.008
  rotX += 0.0016
  if (launched) {
    offsetX += vx
    offsetY += vy
    if (Math.hypot(offsetX, offsetY) > Math.max(width, height) * 0.72) finish()
  }
  for (let i = 0; i < points.length; i += 1) {
    const view = project(points[i], radius)
    const node = nodes[i]
    node.style.transform = `translate(${(width / 2 + view.x + offsetX).toFixed(1)}px, ${(height / 2 + view.y + offsetY).toFixed(1)}px) translate(-50%, -50%) scale(${view.scale.toFixed(3)})`
    node.style.opacity = (0.28 + view.front * 0.72).toFixed(3)
    node.style.zIndex = String(Math.round(view.front * 100))
  }
  frame = requestAnimationFrame(tick)
}

function push(event) {
  if (launched || finished) return
  const root = stage.value
  const rect = root.getBoundingClientRect()
  const dx = event.clientX - (rect.left + rect.width / 2)
  const dy = event.clientY - (rect.top + rect.height / 2)
  const length = Math.hypot(dx, dy) || 1
  const speed = 16
  vx = (dx / length) * speed
  vy = (dy / length) * speed
  launched = true
}

function finish() {
  if (finished) return
  finished = true
  cancelAnimationFrame(frame)
  leaving.value = true
  window.setTimeout(() => emit('done'), 380)
}

onMounted(() => {
  const root = stage.value
  sphere(168)
  for (const point of points) {
    const node = document.createElement('span')
    node.className = point.hot ? 'word hot' : 'word'
    node.textContent = point.text
    root.appendChild(node)
    nodes.push(node)
  }
  frame = requestAnimationFrame(tick)
})

onUnmounted(() => {
  cancelAnimationFrame(frame)
})
</script>

<style scoped>
.stage {
  position: fixed;
  inset: 0;
  z-index: 4000;
  overflow: hidden;
  background: #fff;
  color: #161616;
  cursor: pointer;
  font-family: "Times New Roman", Times, "Songti SC", "SimSun", serif;
}

.stage.leaving {
  opacity: 0;
  transition: opacity 0.38s ease;
  pointer-events: none;
}

.kicker,
.hint {
  position: absolute;
  z-index: 3;
  margin: 0;
  background: #fff;
}

.kicker {
  top: 10px;
  left: 14px;
  font-size: 14px;
  letter-spacing: 0.04em;
}

.hint {
  left: 14px;
  bottom: 12px;
  font-size: 13px;
  color: #444;
}

.stage :deep(.word) {
  position: absolute;
  top: 0;
  left: 0;
  font-size: 13px;
  line-height: 1;
  white-space: nowrap;
  pointer-events: none;
  will-change: transform;
}

.stage :deep(.word.hot) {
  color: #e10600;
}
</style>
