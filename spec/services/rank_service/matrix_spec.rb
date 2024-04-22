require "rails_helper"

describe RankService::Matrix do
  context "Basics" do
    let(:rank_pages) {
      p1 = RankService::Page.new(id: 31, position: 1, start_rank: 1.0 / 3.0)
      p2 = RankService::Page.new(id: 3, position: 2, start_rank: 1.0 / 3.0)
      p3 = RankService::Page.new(id: 47, position: 3, start_rank: 1.0 / 3.0)

      p1.back_links = {2 => p2}
      p2.back_links = {1 => p1, 3 => p3}
      [p1, p2, p3]
    }

    it "can be initialized with an array of rank_pages" do
      matrix = RankService::Matrix.new rank_pages
      expect(matrix).to be
    end

    it "can generate the Matrix" do
      matrix = RankService::Matrix.new rank_pages
      matrix.generate_matrix
      expect(matrix.instance_variable_get(:@matrix)).to be
      expect(matrix.instance_variable_get(:@matrix).row_size).to eql(rank_pages.size)
      expect(matrix.instance_variable_get(:@matrix).column_size).to eql(rank_pages.size)
    end

    it "can iterate a few times" do
      matrix = RankService::Matrix.new rank_pages
      matrix.generate_matrix

      expect {
        matrix.iterate_times(10)
      }.to_not raise_error
    end
  end
end
