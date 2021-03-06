require "test/unit"
require "stringio"
require_relative "../lib/atmessages"
require_relative "../lib/atmessages2"
require_relative "../lib/atmessages3"
 
class TestAtMessages2 < Test::Unit::TestCase
  
  def setup
    @atm = AtMessages.new("data/atmessages_graph2.dat","data",3,3,5)
    @at2 = AtMessages2.new("data/atmessages_graph2.dat","data",3,3,5,0,100,5)
    @at3 = AtMessages3.new("data/atmessages_graph2.dat","data",3,3,5,0,100,5)
    @atm.filter_users_by_messages
    @atm.filter_graph_by_users
    @atm.build_graph
    @atm.find_degrees_edges
    @at2.rebuild_rec_graph
    @at2.build_message_count
  end
  
  def assert_file_equal(string,filename)
    File.open(filename,"r") do |file|
      str = file.gets(nil)
      assert_equal(string,str)
    end
    File.delete(filename)
  end
  
  def teardown
    # Check the Reciprocated and Unreciprocated Graphs Generated
    assert_file_equal("10\t11\t4\t1 2 3 4\n10  13\t3\t8123123 123 12312 3\n14  15  3 1123123 13123 12312\n14  13  6 1 2 3 4 5 6\n11  10\t4\t12312312 12313 123 232\n13  10  3 11123123 123123 213123\n13  14  3 1123 123123 1234\n15  13  4 2 3 4 5\n15  14  5 1 2 3 4 5\n16  11  5 1 2 3 4 5\n","data/003.txt")
    assert_file_equal("10 9\n14 9\n11 4\n13 6\n15 12\n16 5\n","data/people_003.txt")
    assert_file_equal("10 11\n10 13\n14 15\n14 13\n11 10\n13 10\n13 14\n15 14\n","data/003_003_rec.txt")
    assert_file_equal("15 13\n16 11\n","data/003_003_unr.txt")
    assert_file_equal("10 11\n11 10\n","data/003_004_rec.txt")
    assert_file_equal("15 13\n16 11\n","data/003_004_unr.txt")
    assert_file_equal("11 2 1\n10 2 2\n13 3 2\n15 1 2\n14 2 2\n16 0 1\n","data/people_003_degree.txt")
    assert_file_equal("10 11\n10 13\n14 15\n14 13\n11 10\n13 10\n13 14\n15 13\n15 14\n16 11\n","data/people_003_edges.txt")
    assert_file_equal(nil,"data/003_005_rec.txt")
    assert_file_equal("16 11\n","data/003_005_unr.txt")
    assert_file_equal("10 7 7\n11 9 4\n13 13 6\n14 8 9\n15 3 9\n16 0 5\n","data/people_003_msg.txt")
  end
  
  def test_rebuild_rec_graph
    assert_file_equal("11 10\n13 10\n15 14\n14 13\n","data/003_003_recn.txt")
    assert_file_equal("11 10\n","data/003_004_recn.txt")
    assert_file_equal(nil,"data/003_005_recn.txt")
  end
  
  def test_build_unrec_connected_components
    @at2.build_unrec_connected_components
    assert_file_equal("2 2 \n","data/003_003_unr_cc.txt")
    assert_file_equal("2 2 \n","data/003_004_unr_cc.txt")
    assert_file_equal("2 \n","data/003_005_unr_cc.txt")
  end
  
  def test_build_rur_edge_count
    @at2.build_unrec_connected_components
    @at2.build_rur_edge_count(3)
  end
  
  def test_build_rur_outdegrees
    @atm.filter_users_by_messages
    @atm.filter_graph_by_users
    @atm.build_graph
    @at2.build_rur_outdegrees
    @atm.find_degrees_edges
    #@at2.build_rur_prediction
    
    @at2.build_message_count
    # @at2.build_rur_prediction(:inmsg)
    # @at2.build_rur_prediction(:msgdeg)
    # @at2.build_rur_prediction(:inoutdeg)
    # @at2.build_rur_prediction(:mutualin_nbrs)
    # @at2.build_rur_prediction(:mutualin_abs)
    # @at2.build_rur_prediction(:mutualin_wnbrs)
    # @at2.build_rur_prediction(:pagerank)
    # @at2.build_rur_prediction(:prefattach)
    @at2.build_rur_prediction(:inoutdeg,:directed_percentiles)
    @at2.build_rur_prediction(:katz_out,:percentiles)
    @at2.build_rur_prediction(:katz_out,:directed_percentiles)
    @at2.build_rur_prediction(:katz_out,:directed_onesided_percentiles)
    @at2.build_rur_prediction(:katzdir_in,:percentiles)
    @at2.build_rur_prediction(:katzdir_out,:percentiles)
    @at2.build_rur_prediction(:mutual_abs_in,:percentiles)
    @at2.build_rur_prediction(:mutual_abs_in,:directed_percentiles)
    @at2.build_rur_prediction(:indegree,:percentiles)
    @at2.build_rur_prediction(:prefattach_vw,:percentiles)
    @at2.build_rur_prediction(:indegree,:directed_v_percentiles)
    #@at2.build_rur_preds(:pagerank)
    
    @at3.generate_csv_files(3)
    @at3.generate_csv_files_simple(3)
    @at3.generate_csv_files_paths(3)
    @at3.generate_csv_files_link(3)
    @at3.generate_csv_files_vw(3)
    @at3.generate_csv_files_from_parts(3,"all2",['simple','paths','link','vw'])
    @at3.decision_tree_generate(3,"all")
    @at3.decision_tree_generate(3,"simple")
    @at3.decision_tree_generate(3,"vw")
    @at3.decision_tree_generate(3,"all2")
    @at3.decision_tree_generate_rev(3,"all2")
    
    assert_file_equal("10 2 0 0\n14 2 0 0\n11 1 0 1\n13 2 0 1\n15 1 1 0\n16 0 1 0\n","data/003_003_rur_outdegrees.txt")
    assert_file_equal("10 1 0 0\n14 0 0 0\n11 1 0 1\n13 0 0 1\n15 0 1 0\n16 0 1 0\n","data/003_004_rur_outdegrees.txt")
    assert_file_equal("10 0 0 0\n14 0 0 0\n11 0 0 1\n13 0 0 0\n15 0 0 0\n16 0 1 0\n","data/003_005_rur_outdegrees.txt")
  end
  
end