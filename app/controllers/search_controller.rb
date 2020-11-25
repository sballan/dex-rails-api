class SearchController < ApplicationController

  def index
    @text = params[:text]
    command = Command::Search.new @text
    command.run!
    @pages = command.payload
  end
end
