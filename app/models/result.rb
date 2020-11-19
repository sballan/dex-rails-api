class Result < ApplicationRecord
  belongs_to :query
  belongs_to :page

  validates_presence_of :kind
  validates_uniqueness_of :kind, scope: [:query_id, :page_id]

end
