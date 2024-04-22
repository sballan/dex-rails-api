# == Schema Information
#
# Table name: links
#
#  id      :integer          not null, primary key
#  text    :string
#  from_id :integer          not null
#  to_id   :integer          not null
#
# Indexes
#
#  index_links_on_from_id                     (from_id)
#  index_links_on_to_id                       (to_id)
#  index_links_on_to_id_and_from_id_and_text  (to_id,from_id,text) UNIQUE
#
# Foreign Keys
#
#  from_id  (from_id => pages.id)
#  to_id    (to_id => pages.id)
#
class Link < ApplicationRecord
  belongs_to :to, foreign_key: :to_id, inverse_of: :links_from, class_name: "Page"
  belongs_to :from, foreign_key: :from_id, inverse_of: :links_to, class_name: "Page"

  validates_uniqueness_of :text, scope: [:to_id, :from_id]
end
