Rails.application.configure do
  config.x.site_url = ENV.fetch("SITE_URL", "http://localhost:3000")

  config.x.platform_urls = {
    spotify: ENV.fetch("SPOTIFY_PLAYLIST_URL", "https://open.spotify.com/playlist/1QflIwJwCzmeRhomSnSAld?si=26316d2ee9394deb"),
    apple_music: ENV.fetch("APPLE_MUSIC_PLAYLIST_URL", "https://music.apple.com/us/playlist/pop-punk-queso/pl.u-BNA6rvVsv97Ea")
  }

  config.x.email_signup = ActiveSupport::OrderedOptions.new
  config.x.email_signup.endpoint = ENV.fetch("EMAIL_SIGNUP_ENDPOINT", "")
  config.x.analytics_endpoint = ENV.fetch("ANALYTICS_ENDPOINT", "/track")
end
