class SearchController < ApplicationController
  def search_db
    @text = params[:text]
    @pages = SearchService::Client.search_db(@text)
  end

  def search_cache
    @text = params[:text]
    sanitized_text = IndexService::Client.sanitize_query_text(@text)
    @cache_hits = SearchService::Client.search_cache(sanitized_text)
  end
end
