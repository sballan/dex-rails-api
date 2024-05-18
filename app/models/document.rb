# == Schema Information
#
# Table name: documents
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Document < ApplicationRecord
  has_many :postings, dependent: :destroy

  validates :postings, presence: true
end
