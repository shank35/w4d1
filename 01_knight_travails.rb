require_relative "00_tree_node.rb"

class KnightPathFinder
  MOVES = [ [-2, -1], [-2,  1], [-1, -2], [-1,  2], [ 1, -2], [ 1,  2], [ 2, -1], [ 2,  1] ]
    
  attr_reader :root_node, :considered_positions

  def initialize(start_pos)
    @root_node = PolyTreeNode.new(start_pos)
    @considered_positions = [start_pos]
    build_move_tree
  end

  def self.valid_moves(position)
    valid_moves = []
    current_x, current_y = position
    MOVES.each do |(x, y)|
      new_pos = [current_x + x, current_y + y]
      if new_pos.all? { |coordinate| coordinate.between?(0, 7) }
        valid_moves << new_pos
      end
    end
    valid_moves
  end

  def new_move_positions(pos)
    new_positions = KnightPathFinder.valid_moves(pos).reject do |new_pos|
      @considered_positions.include?(new_pos)
    end
    @considered_positions += new_positions
    new_positions
  end
    
  def build_move_tree
    nodes = [root_node]
    until nodes.empty?
      current_node = nodes.shift
      new_move_positions(current_node.value).each do |new_pos|
        new_node = PolyTreeNode.new(new_pos)
        current_node.add_child(new_node)
        nodes << new_node
      end
    end
  end
    
  def find_path(end_pos)
    end_node = root_node.bfs(end_pos)
    trace_path_back(end_node).reverse.map(&:value)
  end
    
  def trace_path_back(end_node)
    nodes = []
    current_node = end_node
    until current_node.nil?
      nodes << current_node
      current_node = current_node.parent
    end
    nodes
  end
end

kpf = KnightPathFinder.new([0, 0])
p kpf.find_path([2, 1]) # => [[0, 0], [2, 1]]
p kpf.find_path([3, 3]) # => [[0, 0], [2, 1], [3, 3]]
p kpf.find_path([7, 6]) # => [[0, 0], [1, 2], [2, 4], [3, 6], [5, 5], [7, 6]]
p kpf.find_path([6, 2]) # => [[0, 0], [1, 2], [2, 0], [4, 1], [6, 2]]