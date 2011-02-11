require "find_dc.rb"
require "test/unit"
 
class TestFindDC < Test::Unit::TestCase
  
  def citerFunction(cite, citers)
    str = ""
    ft = FindDirectedClosure.new(citers)
    cite.each do |curr,time|
      rc, dc = ft.iterate(curr,time)
      # Print to file
      str += "%d %d\n" % [rc, dc]
    end
    str
  end
 
  def test_simple_graph
    citers = {1=>{}, 2=>{}, 3=>{}, 4=>{}} # user_id => {user_id => time list}
    cite = {1=>1, 2=>2, 3=>3, 4=>4} # user_id => time
    assert_equal("1 0\n2 0\n3 0\n4 0\n", citerFunction(cite,citers))
  end
  
  def test_simple_graph2
    citers = {1=>{}, 2=>{1=>2}, 3=>{}, 4=>{}}
    cite = {1=>1, 2=>3, 3=>4, 4=>5}
    assert_equal("1 0\n2 1\n3 1\n4 1\n", citerFunction(cite,citers))
  end
  
  def test_simple_graph3
    citers = {1=>{}, 2=>{1=>2}, 3=>{1=>4}, 4=>{}}
    cite = {1=>1, 2=>3, 3=>5, 4=>6}
    assert_equal("1 0\n2 1\n3 2\n4 2\n", citerFunction(cite,citers))
  end
  
  def test_simple_graph4
    citers = {1=>{3=>2}, 2=>{}, 3=>{1=>4}, 4=>{}}
    cite = {1=>1, 2=>3, 3=>5, 4=>6}
    assert_equal("1 0\n2 0\n3 1\n4 1\n", citerFunction(cite,citers))
  end
  
  def test_simple_graph5
    citers = {1=>{3=>2}, 2=>{}, 3=>{4=>1}, 4=>{}}
    cite = {1=>1, 2=>3, 3=>5, 4=>6}
    assert_equal("1 0\n2 0\n3 0\n4 0\n", citerFunction(cite,citers))
  end
  
end