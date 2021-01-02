class IndexPageFragmentJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :index

  def perform(page_id, fragment_name)
    page = Page.find(page_id)

    case fragment_name
      when 'title'
        IndexService::Client.index_page_title(page)
      when 'links'
        IndexService::Client.index_page_links(page)
      when 'headers'
        IndexService::Client.index_page_headers(page)
      else
        raise "Invalid fragment name"
    end
  end
end
