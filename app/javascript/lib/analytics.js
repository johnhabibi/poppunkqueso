const ALLOWED_EVENTS = new Set([
  "click_spotify",
  "click_apple_music",
  "click_embedded_player",
])

export function trackEvent(name, properties = {}) {
  if (!ALLOWED_EVENTS.has(name)) {
    return
  }

  if (window.plausible) {
    window.plausible(name, { props: properties })
  }

  if (window.posthog) {
    window.posthog.capture(name, properties)
  }

  if (window.gtag) {
    window.gtag("event", name, properties)
  }

  const endpoint = document.body?.dataset.analyticsEndpoint
  if (endpoint) {
    fetch(endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken(),
      },
      body: JSON.stringify({ event: name, properties }),
      keepalive: true,
    }).catch(() => {})
  }
}

export function bindTrackedLinks() {
  document.querySelectorAll("[data-analytics-event]").forEach((element) => {
    element.addEventListener("click", () => {
      trackEvent(element.dataset.analyticsEvent)
    })
  })
}

function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || ""
}
