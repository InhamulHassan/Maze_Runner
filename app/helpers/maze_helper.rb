# frozen_string_literal: true

# --------------------------------------------------------------------
# Recursive backtracking algorithm for maze generation. Requires that
# the entire maze be stored in memory, but is quite fast, easy to
# learn and implement, and (with a few tweaks) gives fairly good mazes.
# Can also be customized in a variety of ways.
# --------------------------------------------------------------------
module MazeHelper
  class RecBack
    # --------------------------------------------------------------------
    # 1. Set up constants to aid with describing the passage directions
    # --------------------------------------------------------------------

    N = 1
    S = 2
    E = 4
    W = 8
    # DX = {E => 1, W => -1, N => 0, S => 0}.freeze
    # DY = {E => 0, W => 0, N => -1, S => 1}.freeze
    # OPPOSITE = {E => W, W => E, N => S, S => N}.freeze
    DX = {E => 1, W => -1, N => 0, S => 0}.freeze
    DY = {E => 0, W => 0, N => -1, S => 1}.freeze
    OPPOSITE = {E => W, W => E, N => S, S => N}.freeze

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

    # Creates and returns a new RecBack MazeHelper object.
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
      @grid = Array.new(height) {Array.new(width, 0)}
      srand(@seed)
      # start carving the maze passage from the upper-left corner
      carve_passages_from(0, 0, @grid)
    end

    # --------------------------------------------------------------------
    # 3. The recursive-backtracking algorithm itself
    # --------------------------------------------------------------------
    # @param [Object] cx
    # @param [Object] cy

    # @param [Object] grid
    def carve_passages_from(cx, cy, grid)
      # the list of directions the algorithm will be moving to carve the maze passage
      # the array is randomized to minimize bias
      directions = [N, S, E, W].shuffle

      # the algorithm iterates over all the direction (for a given cell coordinate)
      directions.each do |direction|
        # determines the cell coordinate in the given direction
        nx = cx + DX[direction]
        ny = cy + DY[direction]

        # checking if the selected cell is valid or not
        # - it should be within the grid boundaries of the maze
        # - AND it should not have been visited before (zero-valued coordinate)
        unless ny.between?(0, grid.length - 1) && nx.between?(0, grid[ny].length - 1) && grid[ny][nx] == 0
          next
        end

        # carve the cell passage out of the current cell to the next
        grid[cy][cx] |= direction
        grid[ny][nx] |= OPPOSITE[direction]

        # recursively call the function to the new cell
        carve_passages_from(nx, ny, grid)
      end
      @grid = grid
    end

    def print_maze
      out = ''
      out += (' ' + ('_' * (@width * 2 - 1)))
      @height.times do |y|
        out += '|'
        @width.times do |x|
          out += @grid[y][x] & S != 0 ? ' ' : '_'
          out += if @grid[y][x] & E != 0
                   (@grid[y][x] | @grid[y][x + 1]) & S != 0 ? ' ' : '_'
                 else
                   '|'
                 end
        end
        out += ''
      end
    end

    def maze_table
      output = "<table id='maze_table'>"
      # output += '<tr>' + (maze_cell('wall') * (@width * 2)) + '</tr>'
      # output += '<tr>'
      @height.times do |y|
        output += '<tr>'
        # output += maze_cell('left')
        @width.times do |x|
          if grid[y][x] & S != 0
            # Condition 1
            if grid[y][x] & E != 0
              # Scenario 1.1
              output += (@grid[y][x] | @grid[y][x + 1]) & S != 0 ? maze_cell('floor', y, x) : maze_cell('bottom', y, x)
            else
              # Scenario 1.2
              output += maze_cell('right', y, x)
            end
          else
            # Condition 2
            if grid[y][x] & E != 0
              # Scenario 2.1
              output += (@grid[y][x] | @grid[y][x + 1]) & S != 0 ? maze_cell('bottom', y, x) : maze_cell('floor', y, x)
            else
              # Scenario 2.2
              output += maze_cell('right bottom', y, x)
            end
          end
        end
        output += '</tr>'
      end
      output += '</table>'
      output
    end

    def maze_cell(html_class, y = '', x = '')
      html_id = y.to_s + x.to_s
      "<td id='" + html_id + "' class='" + html_class + "'></td>"
    end
  end
end
