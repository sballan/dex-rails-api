class Result < ApplicationRecord
  belongs_to :query
  belongs_to :page

  validates_presence_of :kind
end
