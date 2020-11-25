class SearchController < ApplicationController

  def search_db
    @text = params[:text]
    command = Command::SearchDb.new @text
    command.run!
    @pages = command.payload
  end

  def search_cache
    @text = params[:text]
    command = Command::SearchCache.new @text
    command.run!
    @cache_hits = command.payload
  end
end
