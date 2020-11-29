class ScrapePage < ApplicationRecord
  enum refresh_status: {ready: 0, active: 1, success: 2, failure: 3, invalid: 4}, _prefix: :refresh

  belongs_to :page
end