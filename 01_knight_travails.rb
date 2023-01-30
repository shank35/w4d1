require_relative "00_tree_node.rb"

class KnightPathFinder
  MOVES = [
      [-2, -1],
      [-2,  1],
      [-1, -2],
      [-1,  2],
      [ 1, -2],
      [ 1,  2],
      [ 2, -1],
      [ 2,  1]
  ]
    
  attr_reader :root_node, :considered_positions
    
  def initialize(start_pos)
    @root_node = PolyTreeNode.new(start_pos)
    @considered_positions = [start_pos]
    build_move_tree
  end
    
  def self.valid_moves(pos)
    valid_moves = []
    cur_x, cur_y = pos
    MOVES.each do |(dx, dy)|
      new_pos = [cur_x + dx, cur_y + dy]
      if new_pos.all? { |coord| coord.between?(0, 7) }
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