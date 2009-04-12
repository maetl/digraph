re 'test/unit'
require 'digraph.rb'

class BasicDigraphTest < Test::Unit::TestCase
  
  def setup
    @vertex_set = Set.new [ "A", "B", "C", "D", "E", "F", "G", "H", "I" ]
    @edge_set = Set.new [ ["A","B"],  ["B","C"], ["C","D"], ["C","E"],
    ["A","F"], ["F","G"], ["F","H"], ["G","I"], ["H","I"], ["I","F"] ]
  end
  
  def test_edge_set
    edges = DirectedEdgeSet.new(@edge_set)
    assert_equal(["B","F"].to_set, edges.from("A"))
    assert_equal(["F"].to_set, edges.from("I"))
    assert_equal(["G","H"].to_set, edges.from("F"))
    assert_equal(["I","A"].to_set, edges.to("F"))
    assert_equal(["G","H"].to_set, edges.to("I"))
    assert_equal(["A"].to_set, edges.to("B"))
  end
  
  def test_connected_components
    graph = DigraphManipulator.new(@vertex_set, @edge_set)
    assert(graph.find_scc.include?(["F","G","H","I"]))
  end
  
end

class StronglyConnectedDigraphTest < Test::Unit::TestCase
  
  def setup
    @vertex_set = Set.new ["A","B","C","E","F","G","H"]
    @edge_set = Set.new [ ["A","B"], ["E","A"], ["B","C"], ["B","E"],
    ["B","F"], ["C","D"], ["D","C"], ["E","F"], ["F","G"], ["G","F"],
    ["C","G"], ["G","H"], ["D","H"],  ]
  end
  
  def test_connected_components
    graph = DigraphManipulator.new(@vertex_set, @edge_set)
    assert_equal(graph.find_scc, [["A","B","E"], ["F","G"], ["C","D"],
    ["H"]].to_set)
  end
  
end

