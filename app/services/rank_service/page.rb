class RankService::Page
  attr_reader :id, :position, :start_rank
  attr_accessor :back_links, :finish_rank
  def initialize(id:, position:, start_rank:)
    @id = id
    @position = position
    @start_rank = start_rank
    @back_links = {}
    @finish_rank = nil
  end
end
