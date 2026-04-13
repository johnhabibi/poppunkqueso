require "test_helper"

class ContentRepositoryTest < ActiveSupport::TestCase
  test "loads updates and articles" do
    assert_operator ContentRepository.updates.count, :>=, 3
    assert_operator ContentRepository.articles.count, :>=, 1
  end

  test "finders return matching slugs" do
    update = ContentRepository.find_update("april-heat-check-hooks-heartbreak-ska")
    article = ContentRepository.find_article("best-newer-pop-punk-songs")

    assert_equal "april-heat-check-hooks-heartbreak-ska", update.slug
    assert_equal "best-newer-pop-punk-songs", article.slug
  end
end
