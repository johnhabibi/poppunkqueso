class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  helper_method :platform_urls

  before_action :set_default_meta

  private

  def set_default_meta
    @meta_title = "Pop Punk Queso | Pop Punk + Emo + Ska Playlist"
    @meta_description = "Pop Punk Queso is a curated pop punk playlist brand with emo, ska, and indie side quests. Follow updates, save tracks, and join the monthly queso drop."
    @meta_image = helpers.asset_url("pop-punk-queso-logo.jpg")
    @meta_type = "website"
  end

  def set_meta(title:, description:, image: nil, type: "website")
    @meta_title = title
    @meta_description = description
    @meta_image = image || helpers.asset_url("pop-punk-queso-logo.jpg")
    @meta_type = type
  end

  def platform_urls
    Rails.application.config.x.platform_urls
  end
end
