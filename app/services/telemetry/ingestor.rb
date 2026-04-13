require "uri"
require "cgi"
require "set"

module Telemetry
  class Ingestor
    Result = Struct.new(:ok?, :error, keyword_init: true)

    def initialize(request:, distinct_id:, client: PosthogClient.new)
      @request = request
      @distinct_id = distinct_id
      @client = client
    end

    def call(event_name:, properties:)
      event = event_name.to_s
      return Result.new(ok?: false, error: :invalid_event) unless Schema.valid_event?(event)

      sanitized_properties = sanitize_properties(event, properties)
      return Result.new(ok?: false, error: :invalid_properties) if sanitized_properties.nil?

      payload = sanitized_properties.merge(server_context(sanitized_properties))
      client.capture(event: event, distinct_id: distinct_id, properties: payload)

      Result.new(ok?: true)
    end

    private

    attr_reader :request, :distinct_id, :client

    def sanitize_properties(event, properties)
      return {} if properties.blank?
      return nil unless properties.respond_to?(:to_h)

      raw_hash = properties.to_h
      return nil unless raw_hash.is_a?(Hash)

      allowed_keys = Schema.allowed_properties_for(event).to_set
      sanitized = {}

      raw_hash.each do |raw_key, raw_value|
        key = raw_key.to_s
        return nil if Schema.blocked_property?(key)
        return nil unless allowed_keys.include?(key)
        return nil unless scalar?(raw_value)

        sanitized[key] = normalize_scalar(raw_value)
      end

      sanitized
    end

    def scalar?(value)
      value.is_a?(String) || value.is_a?(Numeric) || value == true || value == false || value.nil?
    end

    def normalize_scalar(value)
      return value unless value.is_a?(String)

      value.strip.first(200)
    end

    def server_context(sanitized_properties)
      referer_uri = parse_uri(request.referer)
      referer_query = parse_query(referer_uri)

      {
        "path" => referer_uri&.path,
        "referrer" => request.referer,
        "user_agent_class" => classify_user_agent(request.user_agent),
        "utm_source" => referer_query["utm_source"],
        "utm_medium" => referer_query["utm_medium"],
        "utm_campaign" => referer_query["utm_campaign"],
        "utm_content" => referer_query["utm_content"],
        "utm_term" => referer_query["utm_term"],
        "content_slug" => sanitized_properties["content_slug"]
      }.compact
    end

    def parse_uri(value)
      return nil if value.blank?

      URI.parse(value)
    rescue URI::InvalidURIError
      nil
    end

    def parse_query(uri)
      return {} unless uri&.query.present?

      CGI.parse(uri.query).transform_values(&:first)
    end

    def classify_user_agent(user_agent)
      return "unknown" if user_agent.blank?

      ua = user_agent.downcase
      return "bot" if ua.match?(/bot|spider|crawl|preview|headless/)
      return "mobile" if ua.match?(/mobile|iphone|android/)
      return "tablet" if ua.match?(/ipad|tablet/)

      "desktop"
    end
  end
end
