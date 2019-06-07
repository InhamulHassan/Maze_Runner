# An implementation of the A* search algorithm. Although this can be used to
# search "perfect" mazes (those without loops), the recursive backtracker is
# more efficient in that case.
class Astar

  # This is the data structure used by the Astar solver to keep track of the
  # current cost of each examined cell and its associated history (path back
  # to the start).
  #
  # Although you will rarely need to use this class, it is documented because
  # applications that wish to visualize the A* algorithm can use the open set
  # of Node instances to draw paths through the maze as the algorithm runs.
  class Node
    include Comparable

    # The maze object that this solver will provide a solution for.
    attr_reader :maze

    # The point (2-tuple array) at which the solution path should begin.
    attr_reader :a

    # The point (2-tuple array) at which the solution path should end.
    attr_reader :b

    # The point in the maze associated with this node.
    attr_accessor :point

    # The path cost of this node (the distance from the start to this cell,
    # through the maze)
    attr_accessor :path_cost

    # The (optimistic) estimate for how much further the exit is from this node.
    attr_accessor :estimate

    # The total cost associated with this node (path_cost + estimate)
    attr_accessor :cost

    # The next node in the linked list for the set that this node belongs to.
    attr_accessor :next

    # The array of points leading from the starting point, to this node.
    attr_reader :history

    def initialize(point, path_cost, estimate, history) #:nodoc:
      @point = point
      @path_cost = path_cost
      @estimate = estimate
      @history = history
      @cost = path_cost + estimate
    end

    def <=>(node) #:nodoc:
      cost <=> node.cost
    end
  end

  # The open set. This is a linked list of Node instances, used by the A*
  # algorithm to determine which nodes remain to be considered. It is always
  # in sorted order, with the most likely candidate at the head of the list.
  attr_reader :open

  def initialize(maze, a = maze.start, b = maze.finish) #:nodoc:
    super
    @open = Node.new(@a, 0, estimate(@a), [])
    @visits = Array.new(@maze.height) { Array.new(@maze.width, 0) }
  end

  def current_solution #:nodoc:
    @open.history + [@open.point]
  end

  def step #:nodoc:
    return false unless @open

    current = @open

    if current.point == @b
      @open = nil
      @solution = current.history + [@b]
    else
      @open = @open.next

      @visits[current.point[1]][current.point[0]] |= current.under ? 2 : 1

      cell = @maze[current.point[0], current.point[1]]

      directions = @maze.potential_exits_at(current.point[0], current.point[1])
      directions.each do |dir|
        try = current.under ? (dir << Theseus::Maze::UNDER_SHIFT) : dir
        if cell & try != 0
          point = move(current.point, dir)
          next unless @maze.valid?(point[0], point[1])
          under = ((@maze[point[0], point[1]] >> Theseus::Maze::UNDER_SHIFT) & @maze.opposite(dir) != 0)
          add_node(point, under, current.path_cost+1, current.history + [current.point])
        end
      end
    end

    return current
  end

  private

  def estimate(pt) #:nodoc:
    Math.sqrt((@b[0] - pt[0])**2 + (@b[1] - pt[1])**2)
  end

  def add_node(pt, under, path_cost, history) #:nodoc:
    return if @visits[pt[1]][pt[0]] & (under ? 2 : 1) != 0

    node = Node.new(pt, path_cost, estimate(pt), history)

    if @open
      p = nil
      n = @open

      while n && n < node
        p = n
        n = n.next
      end

      if p.nil?
        node.next = @open
        @open = node
      else
        node.next = n
        p.next = node
      end

      # remove duplicates
      while node.next && node.next.point == node.point
        node.next = node.next.next
      end
    else
      @open = node
    end
  end

  def move(pt, direction) #:nodoc:
    [pt[0] + @maze.dx(direction), pt[1] + @maze.dy(direction)]
  end
end