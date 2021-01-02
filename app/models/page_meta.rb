class PageMeta < ApplicationRecord
  VALID_STATUSES_ENUM = { new: 0, ready: 1, active: 2, success: 3, failure: 4, dead: 5 }

  enum fetch_status: VALID_STATUSES_ENUM, _prefix: :fetch
  enum index_status: VALID_STATUSES_ENUM, _prefix: :index
  enum rank_status: VALID_STATUSES_ENUM, _prefix: :rank

  belongs_to :page, inverse_of: :meta
end
