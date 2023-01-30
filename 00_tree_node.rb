module Searchable
  # I wrote this as a mixin in case I wanted to later write another
  # TreeNode class (e.g., BinaryTreeNode). All I need is `#children` and
  # `#value` for `Searchable` to work.

  def dfs(target = nil, &prc)
    raise "Need a proc or target" if [target, prc].none?
    prc ||= Proc.new { |node| node.value == target }

    return self if prc.call(self)

    children.each do |child|
      result = child.dfs(&prc)
      return result unless result.nil?
    end

    nil
  end

    def bfs(target = nil, &prc)
      raise "Need a proc or target" if [target, prc].none?
      prc ||= Proc.new { |node| node.value == target }

      nodes = [self]
      until nodes.empty?
        node = nodes.shift

        return node if prc.call(node)
        nodes.concat(node.children)
      end

      nil
    end

  def count
    1 + children.map(&:count).inject(:+)
  end
end

class PolyTreeNode
  include Searchable

  attr_accessor :value
  attr_reader :parent

  def initialize(value = nil)
    @value, @parent, @children = value, nil, []
  end

  def children
    # We dup to avoid someone inadvertently trying to modify our
    # children directly through the children array. Note that
    # `parent=` works hard to make sure children/parent always match
    # up. We don't trust our users to do this.
    @children.dup
  end

  def parent=(parent)
    return if self.parent == parent

    # First, detach from current parent.
    if self.parent
      self.parent._children.delete(self)
    end

    # No new parent to add this to.
    @parent = parent
    self.parent._children << self unless self.parent.nil?

    self
  end

  def add_child(child)
    # Just reset the child's parent to us!
    child.parent = self
  end

  def remove_child(child)
    # Thanks for doing all the work, `parent=`!
    if child && !self.children.include?(child)
      raise "Tried to remove node that isn't a child"
    end

    child.parent = nil
  end

  protected
  
  # Protected method to give a node direct access to another node's
  # children.
  def _children
    @children
  end
end



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