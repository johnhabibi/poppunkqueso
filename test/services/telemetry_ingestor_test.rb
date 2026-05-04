require "test_helper"

class TelemetryIngestorTest < ActiveSupport::TestCase
  RequestStub = Struct.new(:referer, :user_agent)

  class ClientStub
    attr_reader :payload

    def capture(event:, distinct_id:, properties:)
      @payload = {
        event: event,
        distinct_id: distinct_id,
        properties: properties
      }
      true
    end
  end

  test "captures valid event with enriched context" do
    client = ClientStub.new
    request = RequestStub.new(
      "https://poppunkqueso.com/listen?utm_source=ig&utm_medium=social&utm_campaign=spring",
      "Mozilla/5.0 (Macintosh; Intel Mac OS X)"
    )

    result = Telemetry::Ingestor.new(request: request, distinct_id: "anon-123", client: client).call(
      event_name: "click_open_playlist_cta",
      properties: { "platform" => "spotify", "placement" => "hero" }
    )

    assert result.ok?
    assert_equal "click_open_playlist_cta", client.payload[:event]
    assert_equal "anon-123", client.payload[:distinct_id]
    assert_equal "spotify", client.payload[:properties]["platform"]
    assert_equal "hero", client.payload[:properties]["placement"]
    assert_equal "/listen", client.payload[:properties]["path"]
    assert_equal "social", client.payload[:properties]["utm_medium"]
    assert_equal "desktop", client.payload[:properties]["user_agent_class"]
  end

  test "rejects blocked property names" do
    client = ClientStub.new
    request = RequestStub.new(nil, nil)

    result = Telemetry::Ingestor.new(request: request, distinct_id: "anon-123", client: client).call(
      event_name: "click_spotify",
      properties: { "email" => "x@example.com" }
    )

    refute result.ok?
    assert_equal :invalid_properties, result.error
    assert_nil client.payload
  end

  test "rejects unknown property key for event" do
    client = ClientStub.new
    request = RequestStub.new(nil, nil)

    result = Telemetry::Ingestor.new(request: request, distinct_id: "anon-123", client: client).call(
      event_name: "click_spotify",
      properties: { "platform" => "spotify" }
    )

    refute result.ok?
    assert_equal :invalid_properties, result.error
    assert_nil client.payload
  end

  test "rejects non-primitive values even for allowed properties" do
    client = ClientStub.new
    request = RequestStub.new(nil, nil)

    result = Telemetry::Ingestor.new(request: request, distinct_id: "anon-123", client: client).call(
      event_name: "click_open_playlist_cta",
      properties: { "platform" => [ "spotify" ], "placement" => "hero" }
    )

    refute result.ok?
    assert_equal :invalid_properties, result.error
    assert_nil client.payload
  end

  test "normalizes string properties before capture" do
    client = ClientStub.new
    request = RequestStub.new(nil, nil)

    result = Telemetry::Ingestor.new(request: request, distinct_id: "anon-123", client: client).call(
      event_name: "click_spotify",
      properties: { "placement" => "  #{"x" * 220}  " }
    )

    assert result.ok?
    assert_equal 200, client.payload[:properties]["placement"].length
    assert_match(/\Ax+\z/, client.payload[:properties]["placement"])
  end
end
