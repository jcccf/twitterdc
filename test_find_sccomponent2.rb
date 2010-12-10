require "find_sccomponent2.rb"
require "test/unit"
 
class TestSCComponent2 < Test::Unit::TestCase
  
  def citerFunction(cite, citers)
    str = ""
    ft = FindStronglyConnected.new(citers)
    cite.each do |curr|
      rc, ta = ft.iterate(curr)
      # Print to file
      str += "%d %s\n" % [rc, ta]
    end
    str
  end
 
  def test_simple1 # 1 -> 2
    citers = {1=>{2=>true}}
    cite = [1, 2]
    assert_equal("1 \n2  1 1\n", citerFunction(cite,citers))
  end
 
  def test_undirected_graph # 10 <-> 14 <-> 15 <-> 10 and 14 <-> 16
    citers = {16=>{14=>true}, 14=>{16=>true, 15=>true, 10=>true}, 15=>{14=>true, 10=>true}, 10=>{14=>true, 15=>true}}
    cite = [15, 10, 14, 16]
    assert_equal("1 \n2  2\n3  3\n4  4\n", citerFunction(cite,citers))
  end
  
  def test_circular_list # 1 -> 2 -> 3 -> 4 -> 1
    citers = {1=>{2=>true}, 2=>{3=>true}, 3=>{4=>true}, 4=>{1=>true}}
    cite = [1, 2, 3, 4]
    assert_equal("1 \n2  1 1\n3  1 1 1\n4  4\n", citerFunction(cite,citers))
  end
  
  def test_combine_two_into_one # 1 <-> 2 <-> 5 <-> 3 <-> 4
    citers = {1=>{2=>true}, 2=>{1=>true, 5=>true}, 3=>{4=>true}, 4=>{3=>true, 5=>true}, 5=>{2=>true, 4=>true}}
    cite = [1, 2, 3, 4, 5]
    assert_equal("1 \n2  2\n3  2\n4  2 2\n5  5\n", citerFunction(cite,citers))
  end
  
  def test_combine_two_into_one2 # 1 <-> 2 and 3 <-> 4 and 2 -> 5 -> 4 and 3 -> 6 -> 1
    citers = {1=>{2=>true}, 2=>{1=>true, 5=>true}, 3=>{4=>true, 6=>true}, 4=>{3=>true}, 5=>{4=>true}, 6=>{1=>true}}
    cite = [1, 2, 3, 4, 5, 6]
    assert_equal("1 \n2  2\n3  2\n4  2 2\n5  2 2 1\n6  6\n", citerFunction(cite,citers))
  end
  
end