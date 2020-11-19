class Link < ApplicationRecord
  belongs_to :to, foreign_key: :to_id, inverse_of: :links_from, class_name: "Page"
  belongs_to :from, foreign_key: :from_id, inverse_of: :links_to, class_name: "Page"

  # validates_uniqueness_of :text, scope: [:to_id, :from_id]
end
