class InfoController < ApplicationController
  # GET /info
  # GET /info.json
  def index
    @page_count = Page.count
    @link_count = Link.count
    @query_count = Query.count
    @result_count = Result.count
  end
end
