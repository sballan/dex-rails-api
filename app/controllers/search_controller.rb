class SearchController < ApplicationController

  def search_db
    @text = params[:text]
    @pages = SearchService::Client.search_db(@text)
  end

  def search_cache
    @text = params[:text]
    @cache_hits = SearchService::Client.search_cache(@text)
  end
end
