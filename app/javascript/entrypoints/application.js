import { createApp } from "vue"
import { bindTrackedLinks } from "../lib/analytics"

const components = {}

function mountVueIslands() {
  document.querySelectorAll("[data-vue-component]").forEach((element) => {
    const componentName = element.dataset.vueComponent
    const component = components[componentName]

    if (!component) {
      return
    }

    const props = {}

    if (element.dataset.platforms) {
      props.platforms = JSON.parse(element.dataset.platforms)
    }

    if (element.dataset.endpoint) {
      props.endpoint = element.dataset.endpoint
    }

    if (element.dataset.source) {
      props.source = element.dataset.source
    }

    const fallbackMarkup = element.innerHTML

    try {
      element.innerHTML = ""
      createApp(component, props).mount(element)
    } catch (error) {
      console.error(`Failed to mount Vue component: ${componentName}`, error)
      element.innerHTML = fallbackMarkup
    }
  })
}

function boot() {
  mountVueIslands()
  bindTrackedLinks()
}

document.addEventListener("turbo:load", boot)
document.addEventListener("DOMContentLoaded", boot)
