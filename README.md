# Pop Punk Queso

Pop Punk Queso is a Rails-first, server-rendered music brand hub that started as a Spotify playlist and now supports platform-neutral listening, update posts, SEO content, and portable audience capture.

## Stack and Rationale
- Rails 8 + PostgreSQL: durable conventions, SEO-friendly server rendering, low maintenance complexity.
- Tailwind CSS: fast, consistent design system primitives with minimal CSS debt.
- Vite + Vue 3 islands: lightweight interactivity only where UX benefits (platform selector and email signup states).
- Content-first architecture: YAML-driven updates/articles keeps v1 simple without building a CMS.

## Features in v1
- Pages: Home, About, Listen, Updates index/show, Article template, custom 404.
- File-driven content layer for updates/articles/home rotation.
- Email signup handler placeholder (`POST /email_signups`) with JSON + HTML fallback.
- Analytics abstraction with event names:
  - `click_spotify`
  - `click_apple_music`
  - `email_signup_submit`
  - `click_embedded_player`
- SEO basics: page titles, meta descriptions, Open Graph, Twitter cards, semantic headings, sitemap, robots.

## Setup
Prerequisites:
- Ruby 3.3.0 (see `.ruby-version`)
- PostgreSQL 14+
- Node 22.x (latest compatible LTS lane for this repo; `.nvmrc` and `.node-version` are set to `22`)

1. Install dependencies:
```bash
bundle install
bin/setup-js
```
2. Configure env vars:
```bash
cp .env.example .env
```
3. Create and prepare the database:
```bash
bin/rails db:prepare
```
4. Validate content seed files:
```bash
bin/rails db:seed
```

## Local Development
Run Rails, Tailwind, and Vite together:
```bash
bin/dev
```
- Rails server: http://localhost:3000
- Vite dev server is started by `Procfile.dev`.

### Node/Architecture Standardization
- Ruby in this repo is currently running as `x86_64` on macOS, so `bin/vite` also runs Node as `x64`.
- Use Node 22.x to match `.nvmrc`:
```bash
nvm install
nvm use
```
- Install JS dependencies through the repo wrapper so optional native binaries match runtime architecture:
```bash
bin/setup-js
```

## Content Editing
- Home copy + current rotation: `config/content/home.yml`
- Update entries: `config/content/updates.yml`
- Article entries: `config/content/articles.yml`

## Mascot and Brand Assets
- Current mascot asset: `app/assets/images/pop-punk-queso-logo.jpg`
- If you replace it with an updated commission file, keep the same filename to avoid touching view code.

## Add a New Listening Platform
1. Add env var and config mapping in `config/initializers/poppunk_queso.rb`.
2. Add button in `app/views/shared/_platform_buttons.html.erb`.
3. Add tracking event to:
- `app/javascript/lib/analytics.js` allowlist
- `app/controllers/analytics_events_controller.rb` allowlist
4. If needed, extend `PlatformSelector.vue` options.

## Analytics Wiring
- Frontend tracking utility: `app/javascript/lib/analytics.js`.
- Backend placeholder endpoint: `POST /track` (`AnalyticsEventsController#create`).
- Current behavior logs server-side and supports pass-through to Plausible/PostHog/GA if those globals are present.

## Environment Variables
- `SITE_URL`
- `SPOTIFY_PLAYLIST_URL`
- `APPLE_MUSIC_PLAYLIST_URL`
- `EMAIL_SIGNUP_ENDPOINT`
- `ANALYTICS_ENDPOINT`

## Deployment Notes
- Set `SITE_URL` and platform URLs in production.
- Ensure `sitemap.xml` is reachable and robots allows crawling.
- For real email capture, replace placeholder in `EmailSignupsController` with provider API wiring (Buttondown/ConvertKit/Mailchimp).
- For production analytics, wire a provider script and/or persist events server-side.

## Test and Lint
```bash
bin/rails test
bin/rubocop
```
