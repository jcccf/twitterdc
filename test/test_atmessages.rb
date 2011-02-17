require "test/unit"
require "stringio"
require_relative "../lib/atmessages"
 
class TestAtMessages < Test::Unit::TestCase
  
  def setup
    @atm = AtMessages.new("data/atmessages_graph.dat","data",3,3,5)
  end
  
  def teardown
  end
  
  def assert_file_equal(string,filename)
    File.open(filename,"r") do |file|
      str = file.gets(nil)
      assert_equal(string,str)
    end
    File.delete(filename)
  end
  
  def test_filter_users_by_messages_0
    AtMessages.new("data/atmessages_graph.dat","data",0,3,3).filter_users_by_messages
    assert_file_equal("10 9\n14 3\n11 4\n13 6\n21 1\n15 7\n16 5\n","data/atmsg_people_000.txt")
  end
  
  def test_filter_users_by_messages_3
    @atm.filter_users_by_messages
    assert_file_equal("10 9\n14 3\n11 4\n13 6\n15 7\n16 5\n","data/atmsg_people_003.txt")
  end
  
  def test_filter_users_by_messages_max
    AtMessages.new("data/atmessages_graph.dat","data",10,3,3).filter_users_by_messages
    assert_file_equal(nil,"data/atmsg_people_010.txt")
  end
  
  def test_filter_graph_by_users_1
    @atm.filter_users_by_messages
    @atm.filter_graph_by_users
    assert_file_equal("10\t11\t4\t1 2 3 4\n14  15  3 1123123 13123 12312\n11  10\t4\t12312312 12313 123 232\n10  13\t3\t8123123 123 12312 3\n13  10  3 11123123 123123 213123\n13  14  3 1123 123123 1234\n16  11  5 1 2 3 4 5\n15  13  4 2 3 4 5\n","data/atmsg_graph_003.txt")
  end

  def test_reciprocated_unreciprocated
    @atm.filter_users_by_messages
    @atm.filter_graph_by_users
    @atm.build_graph
    @atm.find_scc
    assert_file_equal("10\t11\t4\t1 2 3 4\n14  15  3 1123123 13123 12312\n11  10\t4\t12312312 12313 123 232\n10  13\t3\t8123123 123 12312 3\n13  10  3 11123123 123123 213123\n13  14  3 1123 123123 1234\n16  11  5 1 2 3 4 5\n15  13  4 2 3 4 5\n","data/atmsg_graph_003.txt")
    assert_file_equal("10 9\n14 3\n11 4\n13 6\n15 7\n16 5\n","data/atmsg_people_003.txt")
    
    # Check the Reciprocated and Unreciprocated Graphs Generated
    assert_file_equal("10 11\n10 13\n11 10\n13 10\n","data/atmsg_graph_003_003_rec.txt")
    assert_file_equal("14 15\n13 14\n16 11\n15 13\n","data/atmsg_graph_003_003_unr.txt")
    assert_file_equal("10 11\n11 10\n","data/atmsg_graph_003_004_rec.txt")
    assert_file_equal("16 11\n15 13\n","data/atmsg_graph_003_004_unr.txt")
    assert_file_equal(nil,"data/atmsg_graph_003_005_rec.txt")
    assert_file_equal("16 11\n","data/atmsg_graph_003_005_unr.txt")
    
    # Check that SCC Generated is Correct
    assert_file_equal(" 3 1 1\n","data/atmsg_graph_003_003_unr_scc.txt")
    assert_file_equal(" 1 1 1 1\n","data/atmsg_graph_003_004_unr_scc.txt")
    assert_file_equal(" 1 1\n","data/atmsg_graph_003_005_unr_scc.txt")
  end  
end