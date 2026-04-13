class UpdatesController < ApplicationController
  def index
    @updates = ContentRepository.updates
    set_meta(
      title: "Pop Punk Queso Updates | New Adds and Rotation Notes",
      description: "Track each Pop Punk Queso update with featured tracks, bands added, and scene notes."
    )
  end

  def show
    @update = ContentRepository.find_update(params[:slug])
    raise ActiveRecord::RecordNotFound unless @update

    set_meta(
      title: "#{@update.title} | Pop Punk Queso Update",
      description: @update.intro,
      type: "article"
    )

    @structured_data = {
      "@context" => "https://schema.org",
      "@type" => "BlogPosting",
      "headline" => @update.title,
      "datePublished" => @update.date.iso8601,
      "description" => @update.intro,
      "mainEntityOfPage" => update_url(@update.slug)
    }
  end
end
