# == Schema Information
#
# Table name: page_meta
#
#  id                :integer          not null, primary key
#  crawl_finished_at :datetime
#  crawl_started_at  :datetime
#  crawl_status      :integer          default("new")
#  fetch_finished_at :datetime
#  fetch_started_at  :datetime
#  fetch_status      :integer          default("new")
#  index_finished_at :datetime
#  index_started_at  :datetime
#  index_status      :integer          default("new")
#  indexed_headers   :boolean          default(FALSE)
#  indexed_links     :boolean          default(FALSE)
#  indexed_title     :boolean          default(FALSE)
#  rank_finished_at  :datetime
#  rank_started_at   :datetime
#  rank_status       :integer          default("new")
#  page_id           :integer          not null
#
# Indexes
#
#  index_page_meta_on_crawl_status  (crawl_status)
#  index_page_meta_on_fetch_status  (fetch_status)
#  index_page_meta_on_index_status  (index_status)
#  index_page_meta_on_page_id       (page_id) UNIQUE
#  index_page_meta_on_rank_status   (rank_status)
#
class PageMeta < ApplicationRecord
  VALID_STATUSES_ENUM = {new: 0, ready: 1, active: 2, success: 3, failure: 4, dead: 5}

  enum fetch_status: VALID_STATUSES_ENUM, _prefix: :fetch
  enum index_status: VALID_STATUSES_ENUM, _prefix: :index
  enum crawl_status: VALID_STATUSES_ENUM, _prefix: :crawl
  enum rank_status: VALID_STATUSES_ENUM, _prefix: :rank

  belongs_to :page, inverse_of: :meta
end
