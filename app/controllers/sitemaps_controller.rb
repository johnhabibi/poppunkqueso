class SitemapsController < ApplicationController
  def show
    @updates = ContentRepository.updates
    @articles = ContentRepository.articles

    respond_to do |format|
      format.xml
    end
  end
end
