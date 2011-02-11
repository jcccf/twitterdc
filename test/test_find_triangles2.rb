require "find_triangles2.rb"
require "test/unit"
 
class TestFindTriangles2 < Test::Unit::TestCase
  
  def citerFunction(cite, citers)
    str = ""
    ft = FindTriangle.new(citers)
    cite.each do |curr|
      rc, tc, sc = ft.iterate(curr)
      # Print to file
      str += "%d %d %d\n" % [rc, tc, sc]
    end
    str
  end
 
  def test_simple_graph # 10 <-> 14 <-> 15 <-> 10 and 14 <-> 16
    citers = {16=>{14=>true}, 14=>{16=>true, 15=>true, 10=>true}, 15=>{14=>true, 10=>true}, 10=>{14=>true, 15=>true}}
    cite = [15, 10, 14, 16]
    assert_equal("1 0 0\n2 0 0\n3 1 3\n4 1 5\n", citerFunction(cite,citers))
  end
  
  def test_simple_graph2 # 1 <-> 2
    citers = {1=>{2=>true}}
    cite = [1, 2]
    assert_equal("1 0 0\n2 0 0\n", citerFunction(cite,citers))
  end
  
  def test_simple_graph3 # 10 <-> 14 <-> 15 <-> 10 (1 triangle)
    citers = {14=>{15=>true, 10=>true}, 15=>{14=>true, 10=>true}, 10=>{14=>true, 15=>true}}
    cite = [15, 10, 14]
    assert_equal("1 0 0\n2 0 0\n3 1 3\n", citerFunction(cite,citers))
  end
  
  def test_simple_graph4 # 16 <-> 14 <-> 15 and 14 <-> 10
    citers = {16=>{14=>true}, 14=>{16=>true, 15=>true, 10=>true}, 15=>{14=>true}, 10=>{14=>true}}
    cite = [15, 10, 14, 16]
    assert_equal("1 0 0\n2 0 0\n3 0 1\n4 0 3\n", citerFunction(cite,citers))
  end
  
  def test_simple_graph5 # 16 <-> 14 <-> 15 <-> 10 (Adding in a line)
    citers = {16=>{14=>true}, 14=>{16=>true, 15=>true}, 15=>{14=>true, 10=>true}, 10=>{15=>true}}
    cite = [15, 10, 14, 16]
    assert_equal("1 0 0\n2 0 0\n3 0 1\n4 0 2\n", citerFunction(cite,citers))
  end
  
  def test_simple_graph6 # 16 <-> 14 <-> 18 <-> 15 <-> 10 (Adding in the middle)
    citers = {16=>{14=>true}, 14=>{16=>true, 18=>true}, 18=>{14=>true, 15=>true}, 15=>{18=>true, 10=>true}, 10=>{15=>true}}
    cite = [15, 10, 14, 16, 18]
    assert_equal("1 0 0\n2 0 0\n3 0 0\n4 0 0\n5 0 3\n", citerFunction(cite,citers))
  end
  
  def test_simple_graph7 # 10 <-> 14 <-> 15 <-> 10 and 14 <-> 16 and 14 <-> 17 <-> 15
    citers = {16=>{14=>true}, 14=>{16=>true, 15=>true, 10=>true, 17=>true}, 15=>{14=>true, 10=>true, 17=>true}, 10=>{14=>true, 15=>true}, 17=>{14=>true, 15=>true}}
    cite = [15, 10, 14, 16, 17]
    assert_equal("1 0 0\n2 0 0\n3 1 3\n4 1 5\n5 2 11\n", citerFunction(cite,citers))
  end
  
  def test_simple_graph7 # 10 <-> 14 <-> 15 <-> 10 and 14 <-> 16 and 14 <-> 17 <-> 15 and 10 <-> 17
    citers = {16=>{14=>true}, 14=>{16=>true, 15=>true, 10=>true, 17=>true}, 15=>{14=>true, 10=>true, 17=>true}, 10=>{14=>true, 15=>true, 17=>true}, 17=>{10=>true, 14=>true, 15=>true}}
    cite = [15, 10, 14, 16, 17]
    assert_equal("1 0 0\n2 0 0\n3 1 3\n4 1 5\n5 4 15\n", citerFunction(cite,citers))
  end
  
end