<script setup>
import { ref } from "vue"
import { trackEvent } from "../lib/analytics"

const props = defineProps({
  endpoint: {
    type: String,
    required: true,
  },
  source: {
    type: String,
    default: "site",
  },
})

const email = ref("")
const state = ref("idle")
const message = ref("")

async function submitForm() {
  if (!email.value.includes("@")) {
    state.value = "error"
    message.value = "Drop a valid email so we can send playlist and merch updates."
    return
  }

  state.value = "loading"
  message.value = ""

  trackEvent("email_signup_submit", { source: props.source })

  try {
    const response = await fetch(props.endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken(),
      },
      body: JSON.stringify({ email: email.value, source: props.source }),
    })

    const payload = await response.json()
    if (!response.ok || !payload.success) {
      throw new Error(payload.message || "Signup failed")
    }

    state.value = "success"
    message.value = payload.message
    email.value = ""
  } catch (error) {
    state.value = "error"
    message.value = error.message || "Signup failed"
  }
}

function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || ""
}
</script>

<template>
  <form class="flex flex-col gap-3 sm:flex-row" @submit.prevent="submitForm">
    <input
      v-model="email"
      type="email"
      required
      placeholder="you@scene-mail.com"
      class="w-full rounded-full border border-ppq-ink/20 px-4 py-3 text-sm"
    >
    <button
      type="submit"
      :disabled="state === 'loading'"
      class="rounded-full bg-gradient-to-r from-ppq-yellow to-ppq-red px-6 py-3 text-sm font-semibold uppercase tracking-wide text-white hover:brightness-95 disabled:opacity-70"
    >
      {{ state === "loading" ? "Submitting..." : "Get updates" }}
    </button>
  </form>
  <p v-if="message" class="mt-3 text-sm" :class="state === 'error' ? 'text-red-700' : 'text-green-700'">
    {{ message }}
  </p>
</template>
