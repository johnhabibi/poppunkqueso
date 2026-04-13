module Telemetry
  module Schema
    EVENT_PROPERTIES = {
      "click_spotify" => %w[placement content_slug],
      "click_apple_music" => %w[placement content_slug],
      "click_embedded_player" => %w[placement content_slug],
      "view_listen_page" => %w[placement],
      "click_updates_nav" => %w[placement],
      "open_update_post" => %w[content_slug],
      "open_article_post" => %w[content_slug],
      "click_open_playlist_cta" => %w[platform placement content_slug],
      "click_external_platform_link" => %w[platform placement content_slug]
    }.freeze

    BLOCKED_PROPERTIES = %w[email name full_name message text body].freeze

    module_function

    def valid_event?(event_name)
      EVENT_PROPERTIES.key?(event_name)
    end

    def allowed_properties_for(event_name)
      EVENT_PROPERTIES.fetch(event_name, EMPTY_ARRAY)
    end

    def blocked_property?(key)
      BLOCKED_PROPERTIES.include?(key)
    end

    EMPTY_ARRAY = [].freeze
  end
end
