class ArticlesController < ApplicationController
  def show
    @article = ContentRepository.find_article(params[:slug])
    raise ActiveRecord::RecordNotFound unless @article

    set_meta(
      title: "#{@article.title} | Pop Punk Queso",
      description: @article.description,
      type: "article"
    )

    @structured_data = {
      "@context" => "https://schema.org",
      "@type" => "Article",
      "headline" => @article.title,
      "datePublished" => @article.date.iso8601,
      "description" => @article.description,
      "mainEntityOfPage" => article_url(@article.slug)
    }
  end
end
