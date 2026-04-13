<script setup>
import { computed, ref } from "vue"
import { trackEvent } from "../lib/analytics"

const props = defineProps({
  platforms: {
    type: Object,
    required: true,
  },
})

const selected = ref("spotify")

const options = computed(() => [
  { key: "spotify", label: "Spotify", event: "click_spotify" },
  { key: "apple_music", label: "Apple Music", event: "click_apple_music" },
])

function openSelected() {
  const option = options.value.find((item) => item.key === selected.value)
  const url = props.platforms[selected.value]

  if (!option || !url) {
    return
  }

  trackEvent(option.event)
  window.open(url, "_blank", "noopener")
}
</script>

<template>
  <div class="rounded-2xl border border-ppq-ink/10 bg-ppq-paper p-4">
    <label class="mb-2 block text-xs font-semibold uppercase tracking-wide text-ppq-muted" for="platform-picker">
      Choose your channel
    </label>
    <div class="flex flex-col gap-3 sm:flex-row">
      <select
        id="platform-picker"
        v-model="selected"
        class="w-full rounded-full border border-ppq-ink/20 bg-white px-4 py-3 text-sm"
      >
        <option v-for="option in options" :key="option.key" :value="option.key">
          {{ option.label }}
        </option>
      </select>
      <button
        type="button"
        class="rounded-full bg-gradient-to-r from-ppq-yellow to-ppq-red px-6 py-3 text-sm font-semibold uppercase tracking-wide text-white hover:brightness-95"
        @click="openSelected"
      >
        Open Platform
      </button>
    </div>
  </div>
</template>
