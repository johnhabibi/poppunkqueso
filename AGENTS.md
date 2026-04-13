# AGENTS

## Repo Rules for Future Coding Agents
- This is a Rails-first, server-rendered app. Keep controllers/views/partials as the primary rendering path.
- Do not convert the app into a SPA.
- Use simple Rails conventions and avoid unnecessary abstractions.
- Vue 3 is allowed only for isolated interactive islands where UX clearly benefits.
- Preserve SEO metadata, structured data, sitemap behavior, and internal linking architecture.
- Keep content architecture file-driven unless a database model is clearly necessary.
- Maintain brand tone: playful, scene-savvy, specific, concise, and polished.
- Keep patches minimal and reviewable; avoid broad refactors without justification.
- Respect existing design language and Tailwind utility patterns.

## Expected Workflow
1. Inspect existing routes/controllers/content files before implementing changes.
2. Prefer editing content in `config/content/*.yml` for copy updates.
3. Add tests for new behavior whenever practical.
4. Run checks before proposing changes:
   - `bin/setup-js` (ensures JS deps match runtime architecture and Node version expectations)
   - `bin/rails test`
   - `bin/rubocop`
5. Call out assumptions and unresolved items clearly in PR/task notes.

## Key Files and Ownership
- App config/env mapping: `config/initializers/poppunk_queso.rb`
- Content source:
  - `config/content/home.yml`
  - `config/content/updates.yml`
  - `config/content/articles.yml`
- Content loading layer: `app/services/content_repository.rb`
- Interactive islands:
  - None currently; keep Vue usage isolated if interactive islands are reintroduced.
- Analytics abstraction:
  - `app/javascript/lib/analytics.js`
  - `app/controllers/analytics_events_controller.rb`

## Guardrails
- Do not add auth/admin or a heavy CMS for v1 tasks unless explicitly requested.
- Keep platform/channel framing under one brand identity (Pop Punk Queso first, platform second).
- Do not remove accessibility basics (semantic headings, readable contrast, meaningful link text).
- Keep Node runtime on 22.x (`.nvmrc`) and avoid mixed arm64/x64 installs on macOS; use `bin/setup-js`.
