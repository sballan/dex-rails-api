require 'matrix'

class PageRank
  DAMPING = 0.85
  def initialize(matrix)
    @matrix = matrix
    @v = Matrix.column_vector([1.0/matrix.row_size] * matrix.row_size)
  end

  def iterate
    @v = @matrix * @v
    @v *= DAMPING * @matrix.row_size
    @v += Matrix.column_vector([(1.0 - DAMPING) / @matrix.row_size] * @matrix.row_size)
  end
end
