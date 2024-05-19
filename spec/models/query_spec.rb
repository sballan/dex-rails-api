# == Schema Information
#
# Table name: queries
#
#  id         :integer          not null, primary key
#  cached_at  :datetime         default(Sat, 01 Jan 0000 00:00:00.000000000 UTC +00:00)
#  text       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_queries_on_text  (text) UNIQUE
#
require "rails_helper"

describe Query, type: :model do
  context "Basics" do
    let(:text) { "My Search Term" }

    it "can be created with text" do
      expect(Query.create(text: text)).to be_truthy
    end
  end
end
