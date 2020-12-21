class PageMatch < ApplicationRecord
  belongs_to :query
  belongs_to :page

  validates_presence_of :kind, :full, :distance, :length
end
