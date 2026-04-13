require "test_helper"

class SiteFlowTest < ActionDispatch::IntegrationTest
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
