# Classes: Board

# Let's write a class that represents a basic grid-based "game board",
# as in chess, checkers, tic-tac-toe, Go, and so on.  This is *only* the board
# and it contains absolutely no game-specific logic.

# The goal of this kata is to build familiarity with RSpec tests and their
# output.  Below it the skeleton of the Board class. Implement the behavior
# implied by the tests in specs/board_spec.rb.  Run the spec with
#
#  rspec specs/board_spec.rb
#
# Aim for two things:
#   1. Every test passes (green)
#   2. Your code respects the intention behind the tests (don't be too literal)
#
# NOTE: You do NOT need to modify the initialize method.

class Board
  attr_reader :board, :row_count, :column_count
  # These are now, e.g., Board::DimensionError
  class DimensionError < StandardError;end
  class CellError < StandardError;end

  attr_reader :row_count, :column_count

  # Allow rectangular boards.
  def initialize(row_count, column_count)
    unless row_count > 0
      raise DimensionError, "row_count must be > 0 (got #{row_count})"
    end

    unless column_count > 0
      raise DimensionError, "column_count must be > 0 (got #{column_count})"
    end

    @row_count    = row_count
    @column_count = column_count

    @board = Array.new(@row_count) { Array.new(@column_count) }
  end

  def get(row, column)
    raise_unless_dimensions_valid!(row, column)
    @board[row][column]
  end

  def place(row, column, piece)
    raise_unless_dimensions_valid!(row, column)
    if @board[row][column] != nil
      raise CellError, "this space is already occupied"
    else
      @board[row][column] = piece
    end
  end

  def remove(row, column)
    raise_unless_dimensions_valid!(row, column)
    if @board[row][column] == nil
      raise CellError, "this space is is already empty"
    else
      @board[row][column] = nil
    end
  end

  private
  def raise_unless_dimensions_valid!(row, column)
    if row >= @row_count
      raise DimensionError, "row must be < #{@row_count}"
    elsif column >= @column_count
      raise DimensionError, "column must be > #{@column_count}"
    end
    # Implement a single method that checks for the dimensions given and raises
    # a DimensionError unless they're valid. We don't need to test this method
    # because it's private.
  end
end
