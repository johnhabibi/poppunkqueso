Rails.application.configure do
  config.x.site_url = ENV.fetch("SITE_URL", "http://localhost:3000")

  config.x.platform_urls = {
    spotify: ENV.fetch("SPOTIFY_PLAYLIST_URL", "https://open.spotify.com/playlist/1QflIwJwCzmeRhomSnSAld?si=26316d2ee9394deb"),
    apple_music: ENV.fetch("APPLE_MUSIC_PLAYLIST_URL", "https://music.apple.com/us/playlist/pop-punk-queso/pl.u-BNA6rvVsv97Ea")
  }

  config.x.analytics_endpoint = ENV.fetch("ANALYTICS_ENDPOINT", "/track")
  config.x.telemetry_enabled = ActiveModel::Type::Boolean.new.cast(ENV.fetch("TELEMETRY_ENABLED", "true"))
  config.x.posthog_host = ENV.fetch("POSTHOG_HOST", "https://us.i.posthog.com")
  config.x.posthog_project_api_key = ENV["POSTHOG_PROJECT_API_KEY"]
  config.x.posthog_public_key = ENV["POSTHOG_PROJECT_API_KEY"]
end
