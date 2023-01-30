module Searchable

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

  attr_reader :value, :parent, :children

  def initialize(value = nil)

    @value = value
    @parent = nil
    @children = []

  end

  def parent=(parent)
    if self.parent
      self.parent.children.delete(self)
    end
    @parent = parent 
    self.parent.children << self unless self.parent.nil?
  end

  def add_child(child)
    child.parent = self
  end

  def remove_child(child)
    if child && !self.children.include?(child)
      raise 'not the child!'
    end
    child.parent = nil
  end

end



