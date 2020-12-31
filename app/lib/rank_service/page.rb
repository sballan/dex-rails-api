class RankService::Page
  attr_reader :id, :position, :back_links, :start_rank
  attr_accessor :finish_rank
  def initialize(id:, position:, back_links:, start_rank:)
    @id, @position, @back_links, @start_rank = id, position, back_links, start_rank
  end
end