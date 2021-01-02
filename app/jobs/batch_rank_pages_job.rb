class BatchRankPagesJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :rank

  def perform(page_ids, depth)
    batch.open do
      page_ids.each do |page_id|
        RankPageJob.perform_later(page_id, depth)
      end
    end
  end
end
