class RankPageJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :rank

  def perform(page_id, depth)
    page = Page.find(page_id)
    RankService::Client.rank_from_start_page(page, depth)
  end
end
