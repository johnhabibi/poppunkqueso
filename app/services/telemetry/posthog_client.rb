require "net/http"
require "uri"
require "json"

module Telemetry
  class PosthogClient
    CAPTURE_PATH = "/capture/".freeze

    def initialize(
      host: Rails.application.config.x.posthog_host,
      api_key: Rails.application.config.x.posthog_project_api_key,
      enabled: Rails.application.config.x.telemetry_enabled
    )
      @host = host
      @api_key = api_key
      @enabled = enabled
    end

    def capture(event:, distinct_id:, properties:)
      return true unless enabled?

      if api_key.blank?
        FailureLogger.warn_rate_limited(
          :missing_posthog_key,
          "[telemetry] missing POSTHOG_PROJECT_API_KEY while telemetry is enabled"
        )
        return false
      end

      uri = URI.parse("#{host}#{CAPTURE_PATH}")
      request = Net::HTTP::Post.new(uri.request_uri, { "Content-Type" => "application/json" })
      request.body = {
        api_key: api_key,
        event: event,
        distinct_id: distinct_id,
        properties: properties
      }.to_json

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 2, read_timeout: 2) do |http|
        http.request(request)
      end

      return true if response.is_a?(Net::HTTPSuccess)

      FailureLogger.warn_rate_limited(
        :"posthog_http_#{response.code}",
        "[telemetry] posthog_request_failed status=#{response.code} event=#{event}"
      )
      false
    rescue StandardError => e
      FailureLogger.warn_rate_limited(
        :"posthog_exception_#{e.class.name}",
        "[telemetry] posthog_exception class=#{e.class} event=#{event} message=#{e.message}"
      )
      false
    end

    private

    attr_reader :host, :api_key

    def enabled?
      @enabled
    end
  end
end
