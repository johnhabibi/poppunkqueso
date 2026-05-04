require "test_helper"

class SiteFlowTest < ActionDispatch::IntegrationTest
  parallelize(workers: 1)

  test "core pages render" do
    get root_path
    assert_response :success
    assert_select "h1", /favorite pop punk playlist/i

    get about_path
    assert_response :success

    get listen_path
    assert_response :success
    assert_select "[data-analytics-view='view_listen_page']"

    get updates_path
    assert_response :success

    get update_path("feb-26-adds-no-pressure-hot-mulligan-arms-length")
    assert_response :success
    assert_select "[data-analytics-view='open_update_post']"

    get article_path("best-newer-pop-punk-songs")
    assert_response :success
    assert_select "[data-analytics-view='open_article_post']"
  end

  test "sitemap responds as xml" do
    get "/sitemap.xml"
    assert_response :success
    assert_equal "application/xml; charset=utf-8", response.headers["Content-Type"]
    assert_includes response.body, "<urlset"
  end

  test "analytics endpoint accepts known event" do
    post "/track", params: { event: "click_spotify", properties: { placement: "test" } }, as: :json

    assert_response :accepted
    assert_includes response.headers["Set-Cookie"], "ppq_anon_id="
  end

  test "layout does not load PostHog browser capture or identify wiring" do
    get root_path

    assert_response :success
    assert_no_match(/posthog\.init/, response.body)
    assert_no_match(/capture_pageview/, response.body)
    assert_no_match(/capture_pageleave/, response.body)
    assert_no_match(/data-analytics-anon-id/, response.body)
  end

  test "analytics endpoint forwards accepted event through telemetry client" do
    captured = []
    client = Class.new do
      define_method(:initialize) do |captures|
        @captures = captures
      end

      define_method(:capture) do |event:, distinct_id:, properties:|
        @captures << {
          event: event,
          distinct_id: distinct_id,
          properties: properties
        }
        true
      end
    end.new(captured)

    original_new = Telemetry::PosthogClient.method(:new)
    Telemetry::PosthogClient.define_singleton_method(:new) { client }

    post "/track", params: { event: "click_spotify", properties: { placement: "test" } }, as: :json

    assert_response :accepted
    assert_equal 1, captured.length
    assert_equal "click_spotify", captured.first[:event]
    assert_match(/\A[0-9a-f-]{36}\z/, captured.first[:distinct_id])
    assert_equal "test", captured.first[:properties]["placement"]
  ensure
    Telemetry::PosthogClient.define_singleton_method(:new) do |*args, **kwargs, &block|
      original_new.call(*args, **kwargs, &block)
    end
  end

  test "analytics endpoint rejects unknown event" do
    post "/track", params: { event: "unknown_event", properties: {} }, as: :json

    assert_response :unprocessable_entity
  end

  test "analytics endpoint rejects disallowed properties" do
    post "/track", params: { event: "click_spotify", properties: { email: "nope@example.com" } }, as: :json

    assert_response :unprocessable_entity
  end

  test "analytics endpoint reuses anonymous id cookie" do
    post "/track", params: { event: "click_spotify", properties: {} }, as: :json
    first_cookie = cookies[:ppq_anon_id]
    assert first_cookie.present?

    post "/track", params: { event: "click_spotify", properties: {} }, as: :json

    assert_equal first_cookie, cookies[:ppq_anon_id]
  end

  test "unknown routes render custom 404" do
    get "/this-route-does-not-exist"

    assert_response :not_found
    assert_includes response.body, "stage-dived out of bounds"
  end
end
