require "test/unit"
require "stringio"
require_relative "../lib/atmessages"
require_relative "../lib/atmessages2"
 
class TestAtMessages2 < Test::Unit::TestCase
  
  def setup
    @atm = AtMessages.new("data/atmessages_graph.dat","data",3,3,5)
    @at2 = AtMessages2.new("data/atmessages_graph.dat","data",3,3,5,75,90,25)
  end
  
  def assert_file_equal(string,filename)
    File.open(filename,"r") do |file|
      str = file.gets(nil)
      assert_equal(string,str)
    end
    File.delete(filename)
  end
  
  def base_tests
    # Check the Reciprocated and Unreciprocated Graphs Generated
    assert_file_equal("10\t11\t4\t1 2 3 4\n10  13\t3\t8123123 123 12312 3\n14  15  3 1123123 13123 12312\n11  10\t4\t12312312 12313 123 232\n13  10  3 11123123 123123 213123\n13  14  3 1123 123123 1234\n15  13  4 2 3 4 5\n16  11  5 1 2 3 4 5\n","data/atmsg_graph_003.txt")
    assert_file_equal("10 9\n14 3\n11 4\n13 6\n15 7\n16 5\n","data/atmsg_people_003.txt")
    assert_file_equal("10 11\n10 13\n11 10\n13 10\n","data/atmsg_graph_003_003_rec.txt")
    assert_file_equal("14 15\n13 14\n15 13\n16 11\n","data/atmsg_graph_003_003_unr.txt")
    assert_file_equal("10 11\n11 10\n","data/atmsg_graph_003_004_rec.txt")
    assert_file_equal("15 13\n16 11\n","data/atmsg_graph_003_004_unr.txt")
    assert_file_equal(nil,"data/atmsg_graph_003_005_rec.txt")
    assert_file_equal("16 11\n","data/atmsg_graph_003_005_unr.txt")
  end
  
  def test_rebuild_rec_graph
    @atm.filter_users_by_messages
    @atm.filter_graph_by_users
    @atm.build_graph
    @at2.rebuild_rec_graph
    
    base_tests
    
    assert_file_equal("11 10\n13 10\n","data/atmsg_graph_003_003_recn.txt")
    assert_file_equal("11 10\n","data/atmsg_graph_003_004_recn.txt")
    assert_file_equal(nil,"data/atmsg_graph_003_005_recn.txt")
  end
  
  def test_build_rur_edge_count
    @atm.filter_users_by_messages
    @atm.filter_graph_by_users
    @atm.build_graph
    @at2.rebuild_rec_graph
    @at2.build_rur_edge_count
    
    assert_file_equal("3 2 4 0.5\n4 1 2 0.5\n5 0 1 0.0\n","data/atmsg_graph_003_rur_003-005_ecount.txt")
  end
  
  def test_build_unrec_connected_components
    @atm.filter_users_by_messages
    @atm.filter_graph_by_users
    @atm.build_graph
    @at2.build_unrec_connected_components
    
    assert_file_equal("3 2 \n","data/atmsg_graph_003_003_unr_cc.txt")
    assert_file_equal("2 2 \n","data/atmsg_graph_003_004_unr_cc.txt")
    assert_file_equal("2 \n","data/atmsg_graph_003_005_unr_cc.txt")
  end
  
  def test_build_rur_outdegrees
    @atm.filter_users_by_messages
    @atm.filter_graph_by_users
    @atm.build_graph
    @at2.build_rur_outdegrees
    
    assert_file_equal("10 2 0 0\n14 0 1 1\n11 1 0 1\n13 1 1 1\n15 0 1 1\n16 0 1 0\n","data/atmsg_graph_003_003_rur_outdegrees.txt")
    assert_file_equal("10 1 0 0\n14 0 0 0\n11 1 0 1\n13 0 0 1\n15 0 1 0\n16 0 1 0\n","data/atmsg_graph_003_004_rur_outdegrees.txt")
    assert_file_equal("10 0 0 0\n14 0 0 0\n11 0 0 1\n13 0 0 0\n15 0 0 0\n16 0 1 0\n","data/atmsg_graph_003_005_rur_outdegrees.txt")
  end
  
end