require "matrix"

class RankService::Matrix
  DAMPING = 0.85

  # @!attribute [r] rank_pages
  #   @return [Array<RankService::Page>]
  attr_reader :rank_pages

  def initialize(rank_pages, db_page_count)
    @matrix = nil
    @rank_pages = rank_pages.sort_by(&:position)
    @ev = ::Matrix.column_vector(@rank_pages.map(&:start_rank))
    @iterations = 0
    @db_page_count = db_page_count
  end

  def generate_matrix
    @matrix = ::Matrix.build(rank_pages.size, rank_pages.size) do |row, col|
      current_page = @rank_pages[row - 1]
      num_back_links = current_page.back_links.size.to_f
      back_link_page = current_page.back_links[col]

      if back_link_page.present?
        1.0 / num_back_links
      else
        0.0
      end
    end
  end

  def iterate_times(num)
    num.times do
      iterate
    end

    @rank_pages.each_with_index do |rp, i|
      rp.finish_rank = @ev[i, 0]
    end
  end

  private

  def iterate
    @ev = @matrix * @ev
    @ev *= DAMPING
    @ev += ::Matrix.column_vector([(1.0 - DAMPING) / @db_page_count] * @matrix.row_size)
    @iterations += 1
  end
end
