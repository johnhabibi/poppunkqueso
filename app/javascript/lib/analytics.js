const ALLOWED_EVENTS = new Set([
  "click_spotify",
  "click_apple_music",
  "click_embedded_player",
  "view_listen_page",
  "click_updates_nav",
  "open_update_post",
  "open_article_post",
  "click_open_playlist_cta",
  "click_external_platform_link",
])

export function trackEvent(name, properties = {}) {
  if (!ALLOWED_EVENTS.has(name)) {
    return
  }

  const payload = normalizeProperties(properties)

  if (window.plausible) {
    window.plausible(name, { props: payload })
  }

  if (window.gtag) {
    window.gtag("event", name, payload)
  }

  const endpoint = document.body?.dataset.analyticsEndpoint
  if (endpoint) {
    fetch(endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken(),
      },
      body: JSON.stringify({ event: name, properties: payload }),
      keepalive: true,
    }).catch(() => {})
  }
}

export function bindTrackedLinks() {
  document.querySelectorAll("[data-analytics-event]").forEach((element) => {
    if (element.dataset.analyticsBound === "true") {
      return
    }

    element.dataset.analyticsBound = "true"

    element.addEventListener("click", () => {
      trackEvent(element.dataset.analyticsEvent, parseProps(element.dataset.analyticsProps))
    })
  })
}

export function trackViewEvents() {
  document.querySelectorAll("[data-analytics-view]").forEach((element) => {
    if (element.dataset.analyticsViewTracked === "true") {
      return
    }

    element.dataset.analyticsViewTracked = "true"
    trackEvent(element.dataset.analyticsView, parseProps(element.dataset.analyticsProps))
  })
}

function parseProps(rawValue) {
  if (!rawValue) {
    return {}
  }

  try {
    const parsed = JSON.parse(rawValue)
    return normalizeProperties(parsed)
  } catch (_error) {
    return {}
  }
}

function normalizeProperties(properties) {
  if (!properties || typeof properties !== "object" || Array.isArray(properties)) {
    return {}
  }

  const normalized = {}

  Object.entries(properties).forEach(([key, value]) => {
    if (typeof key !== "string") {
      return
    }

    if (
      typeof value === "string" ||
      typeof value === "number" ||
      typeof value === "boolean" ||
      value === null
    ) {
      normalized[key] = value
    }
  })

  return normalized
}

function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || ""
}
