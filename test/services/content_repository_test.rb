require "test_helper"

class ContentRepositoryTest < ActiveSupport::TestCase
  test "loads updates and articles" do
    assert_operator ContentRepository.updates.count, :>=, 3
    assert_operator ContentRepository.articles.count, :>=, 1
  end

  test "finders return matching slugs" do
    update = ContentRepository.find_update("feb-26-adds-no-pressure-hot-mulligan-arms-length")
    article = ContentRepository.find_article("best-newer-pop-punk-songs")

    assert_equal "feb-26-adds-no-pressure-hot-mulligan-arms-length", update.slug
    assert_equal "best-newer-pop-punk-songs", article.slug
  end
end
