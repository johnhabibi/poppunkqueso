xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  [ root_url, about_url, listen_url, updates_url ].each do |url|
    xml.url do
      xml.loc url
      xml.changefreq "weekly"
      xml.priority "0.8"
    end
  end

  @updates.each do |update|
    xml.url do
      xml.loc update_url(update.slug)
      xml.lastmod update.date.iso8601
      xml.changefreq "weekly"
      xml.priority "0.7"
    end
  end

  @articles.each do |article|
    xml.url do
      xml.loc article_url(article.slug)
      xml.lastmod article.date.iso8601
      xml.changefreq "monthly"
      xml.priority "0.6"
    end
  end
end
