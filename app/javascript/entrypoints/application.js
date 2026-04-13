import { createApp } from "vue"
import PlatformSelector from "../components/PlatformSelector.vue"
import EmailSignup from "../components/EmailSignup.vue"
import { bindTrackedLinks } from "../lib/analytics"

const components = {
  PlatformSelector,
  EmailSignup,
}

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

    element.innerHTML = ""
    createApp(component, props).mount(element)
  })
}

function boot() {
  mountVueIslands()
  bindTrackedLinks()
}

document.addEventListener("turbo:load", boot)
document.addEventListener("DOMContentLoaded", boot)
