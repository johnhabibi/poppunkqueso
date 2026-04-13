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

    get updates_path
    assert_response :success

    get update_path("april-heat-check-hooks-heartbreak-ska")
    assert_response :success

    get article_path("best-newer-pop-punk-songs")
    assert_response :success
  end

  test "sitemap responds as xml" do
    get "/sitemap.xml"
    assert_response :success
    assert_equal "application/xml; charset=utf-8", response.headers["Content-Type"]
    assert_includes response.body, "<urlset"
  end

  test "email signup placeholder accepts valid email" do
    post email_signups_path, params: { email: "fan@example.com", source: "test" }, as: :json

    assert_response :success
    assert_equal true, response.parsed_body["success"]
  end

  test "analytics endpoint accepts known event" do
    post "/track", params: { event: "click_spotify", properties: { source: "test" } }, as: :json

    assert_response :accepted
  end

  test "unknown routes render custom 404" do
    get "/this-route-does-not-exist"

    assert_response :not_found
    assert_includes response.body, "stage-dived out of bounds"
  end
end
