import assert from "node:assert/strict"
import test from "node:test"

import { bindTrackedLinks, trackEvent, trackViewEvents } from "../../app/javascript/lib/analytics.js"

function installDom({ elements = [], endpoint = "/track" } = {}) {
  const calls = {
    fetch: [],
    plausible: [],
    gtag: [],
    posthogCapture: 0,
    posthogIdentify: 0,
  }

  global.window = {
    plausible: (...args) => calls.plausible.push(args),
    gtag: (...args) => calls.gtag.push(args),
    posthog: {
      capture: () => {
        calls.posthogCapture += 1
      },
      identify: () => {
        calls.posthogIdentify += 1
      },
    },
  }

  global.document = {
    body: { dataset: { analyticsEndpoint: endpoint } },
    querySelector: (selector) => {
      if (selector === 'meta[name="csrf-token"]') {
        return { getAttribute: () => "csrf-token" }
      }

      return null
    },
    querySelectorAll: (selector) => {
      if (selector === "[data-analytics-event]") {
        return elements.filter((element) => element.dataset.analyticsEvent)
      }

      if (selector === "[data-analytics-view]") {
        return elements.filter((element) => element.dataset.analyticsView)
      }

      return []
    },
  }

  global.fetch = async (...args) => {
    calls.fetch.push(args)
    return { ok: true }
  }

  return calls
}

function elementWithDataset(dataset) {
  const listeners = {}

  return {
    dataset,
    addEventListener: (eventName, callback) => {
      listeners[eventName] = callback
    },
    click: () => listeners.click?.(),
  }
}

test("trackEvent posts allowlisted events to the Rails analytics endpoint", async () => {
  const calls = installDom()

  trackEvent("click_open_playlist_cta", {
    platform: "spotify",
    placement: "home",
    nested: { ignored: true },
  })

  assert.equal(calls.fetch.length, 1)
  const [endpoint, options] = calls.fetch[0]
  assert.equal(endpoint, "/track")
  assert.equal(options.method, "POST")
  assert.equal(options.headers["X-CSRF-Token"], "csrf-token")
  assert.equal(options.keepalive, true)
  assert.deepEqual(JSON.parse(options.body), {
    event: "click_open_playlist_cta",
    properties: {
      platform: "spotify",
      placement: "home",
    },
  })
})

test("trackEvent keeps Plausible and gtag sinks but does not call PostHog browser APIs", () => {
  const calls = installDom()

  trackEvent("click_spotify", { placement: "footer" })

  assert.equal(calls.plausible.length, 1)
  assert.equal(calls.gtag.length, 1)
  assert.equal(calls.posthogCapture, 0)
  assert.equal(calls.posthogIdentify, 0)
})

test("unknown events are ignored in the browser wrapper", () => {
  const calls = installDom()

  trackEvent("unknown_event", { placement: "footer" })

  assert.equal(calls.fetch.length, 0)
  assert.equal(calls.plausible.length, 0)
  assert.equal(calls.gtag.length, 0)
  assert.equal(calls.posthogCapture, 0)
})

test("data-analytics-event click bindings post explicit events", () => {
  const button = elementWithDataset({
    analyticsEvent: "click_external_platform_link",
    analyticsProps: JSON.stringify({ platform: "apple_music", placement: "listen" }),
  })
  const calls = installDom({ elements: [button] })

  bindTrackedLinks()
  button.click()

  assert.equal(calls.fetch.length, 1)
  assert.deepEqual(JSON.parse(calls.fetch[0][1].body), {
    event: "click_external_platform_link",
    properties: {
      platform: "apple_music",
      placement: "listen",
    },
  })
})

test("data-analytics-view bindings post explicit view events once", () => {
  const section = elementWithDataset({
    analyticsView: "view_listen_page",
    analyticsProps: JSON.stringify({ placement: "listen_page" }),
  })
  const calls = installDom({ elements: [section] })

  trackViewEvents()
  trackViewEvents()

  assert.equal(calls.fetch.length, 1)
  assert.deepEqual(JSON.parse(calls.fetch[0][1].body), {
    event: "view_listen_page",
    properties: {
      placement: "listen_page",
    },
  })
})
