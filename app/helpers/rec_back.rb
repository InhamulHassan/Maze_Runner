# --------------------------------------------------------------------
# Recursive backtracking algorithm for maze generation. Requires that
# the entire maze be stored in memory, but is quite fast, easy to
# learn and implement, and (with a few tweaks) gives fairly good mazes.
# Can also be customized in a variety of ways.
# --------------------------------------------------------------------
class RecBack
  # --------------------------------------------------------------------
  # 1. Set up constants to aid with describing the passage directions
  # --------------------------------------------------------------------

  N = 1
  S = 2
  E = 4
  W = 8
  DX = { E => 1, W => -1, N => 0, S => 0 }.freeze
  DY = { E => 0, W =>  0, N => -1, S => 1 }.freeze
  OPPOSITE = { E => W, W =>  E, N => S, S => N }.freeze

  # --------------------------------------------------------------------
  # 2. Allow the maze to be customized via command-line parameters
  # --------------------------------------------------------------------
  # The width of the maze (number of columns).
  attr_accessor :width

  # The height of the maze (number of rows).
  attr_accessor :height

  # The height of the maze (number of rows).
  attr_accessor :seed

  # The maze grid
  attr_reader :grid

  # Creates and returns a new RecBack object.
  #
  # Many options are supported:
  #
  # [:width]       The number of columns in the maze.
  # [:height]      The number of rows in the maze.
  # [:seed]   The maze algorithm to use. This should be a class,
  def initialize(options = {})
    @width = (options[:width] || 10).to_i
    @height = (options[:height] || @width).to_i
    @seed = (options[:seed] || rand(0xFFFF_FFFF)).to_i
    @grid = Array.new(height) { Array.new(width, 0) }

    srand(seed)
  end

  # --------------------------------------------------------------------
  # 3. The recursive-backtracking algorithm itself
  # --------------------------------------------------------------------
  # @param [Object] cx
  # @param [Object] cy

  # @param [Object] grid
  def carve_passages_from(cx, cy)
    directions = [N, S, E, W].sort_by { rand }

    directions.each do |direction|
      nx = cx + DX[direction]
      ny = cy + DY[direction]

      next unless ny.between?(0, @grid.length - 1) && nx.between?(0, @grid[ny].length - 1) && @grid[ny][nx] == 0

      @grid[cy][cx] |= direction
      @grid[ny][nx] |= OPPOSITE[direction]
      carve_passages_from(nx, ny)
    end
  end

  def print
    out = ''
    puts ' ' + '_' * (@width * 2 - 1)
    @height.times do |y|
      out += '|'
      width.times do |x|
        out += grid[y][x] & S != 0 ? ' ' : '_'
        if grid[y][x] & E != 0
          out += (grid[y][x] | grid[y][x + 1]) & S != 0 ? ' ' : '_'
        else
          out += '|'
        end
      end
      out += '\\n'
    end
  end
end
