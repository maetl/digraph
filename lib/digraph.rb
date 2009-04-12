# Digraph Manipulator for extracting strongly connected
# components from a digraph.
# 
# (c) 2006, maetl
# Distributed under the MIT License
#

require 'set'

# Enables graph vertices to be traversed by 
# their incoming or outgoing edges.
#
class DirectedEdgeSet
  
  def initialize(e)
    @edges = e.to_set
  end
  
  def from(v, &b)
    f = @edges.collect do |e|
      if e[0] == v then e[1]; end
    end
    f.compact!
    if b
      f.each { |e| yield e }
    end
    f.to_set
  end
  
  def to(v, &b)
    t = @edges.collect do |e|
      if e[1] == v then e[0]; end
    end
    t.compact!
    if b
      t.each { |e| yield e }
    end
    t.to_set
  end
  
end

# Provides a peek method, treating
# the standard Ruby array as a stack.
#
class Stack < Array
  
  def top
    self[0]
  end
  
end

# A class for manipulating digraphs that are represented as sets.
#
# The constructor accepts a set of Vertex points and a set of edges
# that map between the vertexes.
#
# eg: for the digraph a->b->c, the class can be constructed via:
#     vertex_set = Set.new ["A", "B", "C"]
#     edge_set = Set.new [["A","B"],["B","C"]]
#     graph = DigraphManipulator.new(vertex_set, edge_set)
#
class DigraphManipulator
  
  def initialize(v, e)
    @v = v
    @e = DirectedEdgeSet.new(e)
  end
  
  # clears the graph traversal
  def reset
    @visited = Hash.new
    @index = 0
    @rindex = Hash.new
    @s = Stack.new
    @c = 0
    @in_c = Hash.new
    @v.each do |n|
      @visited[n] = false
    end
  end
  
  # execute a depth first search
  #
  def each_by_depth(&b)
    reset()
    @v.sort
    @v.each do |n|
      if !@visited[n] then each_by_depth_visit(n, b); end
    end
  end
  
  # depth first search visitor
  #
  def each_by_depth_visit(v, proc)
    proc.call(v)
    @visited[v] = true
    @index = @index +1
    @e.from(v) do |w|
      if !@visited[w] then each_by_depth_visit(w, proc); end
    end
  end
  
  # finds the strongly connected components within the digraph.
  #
  # returns Hash of vertices in each cluster
  #
  def find_scc
    reset()
    @v.each do |n|
      if !@visited[n] then find_scc_visit(n); end
    end
    scc = {}
    @rindex.each do |v,c|
      if !scc.has_key?(c)
        scc[c] = [v]
      else
        scc[c] << v
      end
    end
    scc.values.to_set
  end
  
  # Recursive depth first search, while indexing the
  # strongly connected clusters
  #
  # see http://www.mcs.vuw.ac.nz/~djp/files/P05.pdf
  #
  def find_scc_visit(v)
    root = true
    @visited[v] = true
    @rindex[v] = @index
    @index = @index+1
    @in_c[v] = false
    @e.to(v) do |w|
      if !@visited[w] then find_scc_visit(w); end
      if !@in_c[w] and @rindex[w] < @rindex[v]
        @rindex[v] = @rindex[w]
        root = false
      end
    end
    if root
      @in_c[v] = true
      while !@s.empty? and @rindex[v] <= @rindex[@s.top]
        w = @s.pop
        @rindex[w] = @c
        @in_c[w] = true
      end
      @rindex[v] = @c
      @c = @c+1
    else
      @s.push(v)
    end
  end
  
end

