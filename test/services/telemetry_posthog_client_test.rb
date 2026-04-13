require "test_helper"

class TelemetryPosthogClientTest < ActiveSupport::TestCase
  test "returns true and noops when telemetry disabled" do
    client = Telemetry::PosthogClient.new(enabled: false)

    assert client.capture(event: "click_spotify", distinct_id: "anon-1", properties: {})
  end

  test "returns false when request errors" do
    client = Telemetry::PosthogClient.new(enabled: true, api_key: "phc_test", host: "https://us.i.posthog.com")

    original_start = Net::HTTP.method(:start)
    Net::HTTP.define_singleton_method(:start) do |*|
      raise Timeout::Error, "boom"
    end

    begin
      refute client.capture(event: "click_spotify", distinct_id: "anon-1", properties: {})
    ensure
      Net::HTTP.define_singleton_method(:start, original_start)
    end
  end
end
