require "test/unit"
require "stringio"
require_relative "../lib/atmessages"
require_relative "../lib/atmessages2"
require_relative "../lib/atmessages3"
require_relative "../lib/twitterdc/twitterdc"
include TwitterDc
 
class TestDecisionTree < Test::Unit::TestCase
  
  def setup
    @atm = AtMessages.new("data/atmessages_graph3.dat","data",3,3,5)
    @at2 = AtMessages2.new("data/atmessages_graph3.dat","data",3,3,5,0,100,5)
    @at3 = AtMessages3.new("data/atmessages_graph3.dat","data",3,3,5,0,100,5)
    @atm.filter_users_by_messages
    @atm.filter_graph_by_users
    @atm.build_graph
    @atm.find_degrees_edges
    @at2.rebuild_rec_graph
    @at2.build_message_count
    puts "hi!"
    @at2.build_rur_edge_count(3)
    @at2.build_rur_edge_count(4)
    @at2.build_rur_edge_count(5)
    @at2.filter_rur_graph_by_indegree
  end
  
  def assert_file_equal(string,filename)
    File.open(filename,"r") do |file|
      str = file.gets(nil)
      assert_equal(string,str)
    end
    File.delete(filename)
  end
  
  def teardown
    # Basic tests
    assert_file_equal("10\t11\t4\t1 2 3 4\n10  13\t3\t8123123 123 12312 3\n10  19  1 18\n14  15  3 1123123 13123 12312\n14  13  6 1 2 3 4 5 6\n11  10\t4\t12312312 12313 123 232\n13  10  3 11123123 123123 213123\n13  14  3 1123 123123 1234\n15  13  4 2 3 4 5\n15  14  5 1 2 3 4 5\n16  11  5 1 2 3 4 5\n19  14  4 1 2 3 4\n19  15  2 1 2 3\n19  16  3 1 2 3\n","data/003.txt")
    assert_file_equal("10 9\n14 9\n11 4\n13 6\n15 12\n16 5\n19 9\n","data/people_003.txt")
    assert_file_equal("10 11\n10 13\n14 15\n14 13\n11 10\n13 10\n13 14\n15 14\n","data/003_003_rec.txt")
    assert_file_equal("15 13\n16 11\n19 14\n19 16\n","data/003_003_unr.txt")
    assert_file_equal("10 11\n11 10\n","data/003_004_rec.txt")
    assert_file_equal("15 13\n16 11\n19 14\n","data/003_004_unr.txt")
    assert_file_equal("11 2 1\n10 2 3\n13 3 2\n19 1 3\n15 2 2\n14 3 2\n16 1 1\n","data/people_003_degree.txt")
    assert_file_equal("10 11\n10 13\n10 19\n14 15\n14 13\n11 10\n13 10\n13 14\n15 13\n15 14\n16 11\n19 14\n19 15\n19 16\n","data/people_003_edges.txt")
    assert_file_equal(nil,"data/003_005_rec.txt")
    assert_file_equal("16 11\n","data/003_005_unr.txt")
    assert_file_equal("10 7 8\n11 9 4\n13 13 6\n19 1 9\n14 12 9\n15 5 9\n16 3 5\n","data/people_003_msg.txt")
  end
  
  def test_indegree_filter
    assert_file_equal("11 10\n14 13\n","data/003_003_rec_indegree.txt")
    assert_file_equal("19 16\n","data/003_003_unr_indegree.txt")
    assert_file_equal("11 10\n","data/003_004_rec_indegree.txt")
    assert_file_equal(nil,"data/003_004_unr_indegree.txt")
    assert_file_equal(nil,"data/003_005_rec_indegree.txt")
    assert_file_equal(nil,"data/003_005_unr_indegree.txt")
  end
  
  def test_indegree_filter_predictions
    @at2.build_rur_prediction(:indegree,:directed_percentiles,:indegree)
  end
  
  def test_indegree
    @at3.generate_csv_files_indegree(3)
    @at3.decision_tree_generate(3,"indegree")
    @at3.generate_csv_files_simple(3)
    @at3.decision_tree_generate(3,"indegree")
  end
  
  def test_all2bal
    @at3.generate_csv_files_simple(3,true)
    @at3.generate_csv_files_paths(3,true)
    @at3.generate_csv_files_link(3,true)
    @at3.generate_csv_files_from_parts(3, "all2bal", ['simple_bal','paths_bal','link_bal'])
    @at3.decision_tree_generate(3,"all2bal")
    @at3.decision_tree_generate_rev(3,"all2bal")
  end

end