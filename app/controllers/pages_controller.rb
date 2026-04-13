class PagesController < ApplicationController
  def home
    @home = ContentRepository.homepage
    @updates = ContentRepository.updates.first(3)
    set_meta(
      title: "Pop Punk Queso | The Pop Punk Playlist That Actually Gets Updated",
      description: "Pop Punk, emo, ska, and indie side quests. Follow the playlist, catch new additions, and join the monthly queso drop."
    )

    @structured_data = {
      "@context" => "https://schema.org",
      "@type" => "WebSite",
      "name" => "Pop Punk Queso",
      "url" => request.base_url,
      "description" => @meta_description,
      "potentialAction" => {
        "@type" => "SearchAction",
        "target" => "#{request.base_url}/articles/{slug}",
        "query-input" => "required name=slug"
      }
    }
  end

  def about
    set_meta(
      title: "About Pop Punk Queso | Scene-Savvy Playlist Curation",
      description: "Why Pop Punk Queso exists, how we curate, and what makes this playlist a taste-driven lane instead of a random song dump."
    )
  end

  def listen
    set_meta(
      title: "Listen to Pop Punk Queso | Spotify + Apple Music",
      description: "Choose your platform and keep Pop Punk Queso in rotation across Spotify and Apple Music."
    )
  end
end
