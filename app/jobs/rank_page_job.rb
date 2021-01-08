class RankPageJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :rank

  def perform(page_id, depth=150)
    page = Page.find(page_id)
    RankService::Client.rank_from_start_page(page, depth)
  end
end
