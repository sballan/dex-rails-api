require 'matrix'

class RankService::Matrix
  # @!attribute [r] pages
  #   @return [Array<RankService::Page>]
  attr_reader :pages

  def initialize(pages)
    @matrix = nil
    @pages = pages.sort_by(&:position)
    @ev = nil
    @iterations = 0
  end

  def generate_matrix
    @matrix = ::Matrix.build(pages.size, pages.size) do |row, col|
      
    end
  end
end