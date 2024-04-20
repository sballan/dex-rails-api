class IndexPageCallbackJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :index

  def perform(page_id, index_fields)
    page_to_index = Page.includes(:meta).find(page_id)
    index_fields.symbolize_keys!

    success = index_fields[:title] == page_to_index.meta.indexed_title &&
      index_fields[:links] == page_to_index.meta.indexed_links &&
      index_fields[:headers] == page_to_index.meta.indexed_headers

    page_to_index.meta.index_status = success ? :success : :failure
    page_to_index.meta.index_finished_at = DateTime.now.utc
    page_to_index.save!
  end
end
