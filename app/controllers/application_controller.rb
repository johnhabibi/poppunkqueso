class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  helper_method :platform_urls

  before_action :ensure_anonymous_id
  before_action :set_default_meta

  private

  def set_default_meta
    @meta_title = "Pop Punk Queso | Pop Punk + Emo + Ska Playlist"
    @meta_description = "Pop Punk Queso is a curated pop punk playlist brand with emo, ska, and indie side quests. Follow updates, catch new adds, and stay posted on merch drops."
    @meta_image = helpers.asset_url("ppq-share.png")
    @meta_type = "website"
  end

  def ensure_anonymous_id
    cookies.signed.permanent[:ppq_anon_id] ||= SecureRandom.uuid
  end

  def set_meta(title:, description:, image: nil, type: "website")
    @meta_title = title
    @meta_description = description
    @meta_image = image || helpers.asset_url("ppq-share.png")
    @meta_type = type
  end

  def platform_urls
    Rails.application.config.x.platform_urls
  end
end
