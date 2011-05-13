require "test/unit"
require "stringio"
require_relative "../lib/atmessages"
require_relative "../lib/atmessages2"
require_relative "../lib/atmessages3"
require_relative "../lib/twitterdc/twitterdc"
include TwitterDc
 
class TestAtMessages2 < Test::Unit::TestCase
  
  def setup
    @c = Constants.new("abc", 1000, 10, 30)
  end
  
  def teardown
    
  end
  
  def test_degrees_in
    degrees = {1 => 10.0, 2 => 20.0, 3 => 10.0}
    edge_type = :in
    r = ReciprocityHeuristics::DegreeDecision.new(@c,degrees,edge_type)
    assert_equal(r.result(1,2,:rec),9.0/19)
    assert_equal(r.result(2,3,:unr),1.0/(20.0/9))
    assert_equal(r.result(2,1,:unr),1.0/(20.0/9))
    assert_equal(r.result_directed(1,2,:rec),9.0/20)
    assert_equal(r.result_directed(1,2,:unr),10.0/20)
    assert_equal(r.result_directed_onesided(1,2,:unr),20.0)
    assert_equal(r.result_directed_onesided(1,2,:rec),20.0)
  end
  
  def test_degrees_out
    degrees = {1 => 10.0, 2 => 20.0, 3 => 10.0}
    edge_type = :out
    r = ReciprocityHeuristics::DegreeDecision.new(@c,degrees,edge_type)
    assert_equal(r.result(1,2,:rec),9.0/19)
    assert_equal(r.result(2,3,:unr),1.0/(19.0/10))
    assert_equal(r.result(2,1,:unr),1.0/(19.0/10))
    assert_equal(r.result_directed(1,2,:rec),10.0/19)
    assert_equal(r.result_directed(1,2,:unr),10.0/20)
    assert_equal(r.result_directed_onesided(1,2,:unr),20.0)
    assert_equal(r.result_directed_onesided(1,2,:rec),19.0)
  end
  
  def test_messages_in
    messages = { 1 => 19.0, 2 => 24.0, 3 => 31.0 }
    msgedges = { [1,2] => 6.0, [2,1] => 1.0, [2,3] => 5.0, [3,1] => 7.0}
    r = ReciprocityHeuristics::MessagesDecision.new(@c,messages,msgedges,:in)
    assert_equal(1/(18.0/18),r.result(1,2,:rec))
    assert_equal(1/(18.0/18),r.result(1,2,:unr))
    assert_equal(18.0/24,r.result_directed(1,2,:rec))
    assert_equal(18.0/24,r.result_directed(1,2,:unr))
    assert_equal(24,r.result_directed_onesided(1,2,:rec))
    assert_equal(24,r.result_directed_onesided(1,2,:unr))
  end
  
  def test_messages_out
    messages = { 1 => 19.0, 2 => 24.0, 3 => 31.0 }
    msgedges = { [1,2] => 6.0, [2,1] => 1.0, [2,3] => 5.0, [3,1] => 7.0}
    r = ReciprocityHeuristics::MessagesDecision.new(@c,messages,msgedges,:out)
    assert_equal(13.0/23,r.result(1,2,:rec))
    assert_equal(13.0/23,r.result(1,2,:unr))
    assert_equal(19.0/23,r.result_directed(1,2,:rec))
    assert_equal(19.0/23,r.result_directed(1,2,:unr))
    assert_equal(23,r.result_directed_onesided(1,2,:rec))
    assert_equal(23,r.result_directed_onesided(1,2,:unr))
  end
  
  def test_katz
    edges = {1 => [2, 3, 4], 2 => [4], 3 => [1,4], 4 => [3]}
    r = ReciprocityHeuristics::KatzNStepDecision.new(@c,edges)
    assert_equal(0.0,r.result(1,2,:rec)) # Make sure no one step paths considered
    assert_equal(0.0,r.result(1,2,:unr)) # Make sure no one step paths considered
    assert_equal(0.0,r.result(1,3,:unr))
    assert_equal(0.0,r.result(3,1,:unr))
    assert_equal(0.5,r.result(1,4,:rec))
    assert_equal(0.5,r.result(4,1,:unr))
    assert_equal(1.0/22,r.result_directed(1,4,:rec))
    assert_equal(0.5,r.result_directed(4,1,:rec))
    assert_equal(0.0,r.result_directed(1,3,:unr))
    assert_equal(0.05**2/0.05,r.result_directed(3,1,:unr))
    assert_equal(0.05**2,r.result_directed_onesided(1,4,:unr))
    assert_equal(0.05**2*2,r.result_directed_onesided(4,1,:unr))
  end
  
  def test_katz_directed
    edges = {1 => [2, 3, 4], 2 => [4], 3 => [1,4], 4 => [3]}
    r = ReciprocityHeuristics::KatzNStepDirectedDecision.new(@c,edges)
    assert_equal(0.0,r.result(1,2,:rec))
    assert_equal(0.0,r.result(1,2,:unr))
    assert_equal(0.0,r.result(2,1,:rec))
    assert_equal(0.0,r.result(2,1,:unr))
    assert_equal(0.05**2*2,r.result(1,4,:unr))
    assert_equal(0.05**2*2,r.result(1,4,:rec))
    assert_equal(0.05**2,r.result(4,1,:unr))
  end
  
  # Note that these tests aren't totally "logical", since sometimes even when below an edge is "rec", 
  # there might not be a msgedge value between them both ways, although in real data there should be
  def test_messages_per_degree_in
    msgs = {1 => 10.0, 2 => 13.0, 3 => 15.0}
    degs = {1 => 2.0, 2 => 1.0, 3 => 3.0 }
    msgedges = { [1,2] => 5.0, [2,3] => 6.0, [1,3] => 7.0 }
    r = ReciprocityHeuristics::MessagesPerDegreeDecision.new(@c, msgs, degs, msgedges, :in)
    assert_equal(0.0,r.result(1,2,:rec))
    assert_equal(0.4,r.result(1,3,:rec))
    assert_equal(0.8,r.result(1,3,:unr))
    assert_equal(1.0,r.result_directed(1,3,:unr))
    assert_equal(0.5,r.result_directed(1,3,:rec))
    assert_equal(8.0/15,r.result_directed(3,1,:unr))
    assert_equal(0.8,r.result_directed(3,1,:rec))
    assert_equal(5.0,r.result_directed_onesided(1,3,:unr))
    assert_equal(5.0,r.result_directed_onesided(1,3,:rec))
  end
  
  def test_messages_per_degree_out
    msgs = {1 => 10.0, 2 => 13.0, 3 => 15.0}
    degs = {1 => 2.0, 2 => 1.0, 3 => 3.0 }
    msgedges = { [1,2] => 5.0, [2,3] => 6.0, [1,3] => 7.0 }
    r = ReciprocityHeuristics::MessagesPerDegreeDecision.new(@c, msgs, degs, msgedges, :out)
    assert_equal(0.0,r.result(1,2,:rec))
    assert_equal(6.0/15,r.result(1,3,:rec))
    assert_equal(0.6,r.result(1,3,:unr))
    assert_equal(1.0,r.result_directed(1,3,:unr))
    assert_equal(2.0/3,r.result_directed(1,3,:rec))
    assert_equal(0.3,r.result_directed(3,1,:unr))
    assert_equal(0.6,r.result_directed(3,1,:rec))
    assert_equal(5.0,r.result_directed_onesided(1,3,:unr))
    assert_equal(7.5,r.result_directed_onesided(1,3,:rec))
  end
  
  def test_outdegree_per_indegree
    indegrees = {1 => 1.0, 2 => 3.0, 3 => 5.0}
    outdegrees = {1 => 20.0, 2 => 50.0, 3 => 3.0}
    r = ReciprocityHeuristics::OutdegreePerIndegreeDecision.new(@c,indegrees,outdegrees)
    assert_equal(0.0,r.result(1,2,:rec))
    assert_equal(38.0/50,r.result(1,2,:unr))
    assert_equal(1.0/49,r.result(2,3,:rec))
    assert_equal(9.0/196,r.result(2,3,:unr))
    assert_equal(1.0/49,r.result(3,2,:rec))
    assert_equal(4.0/250,r.result(3,2,:unr))
    assert_equal(4.0/250,r.result_directed(2,3,:rec))
    assert_equal(9.0/250,r.result_directed(2,3,:unr))
    assert_equal(2.0/5,r.result_directed_onesided(2,3,:rec))
    assert_equal(3.0/5,r.result_directed_onesided(2,3,:unr))
  end
  
  def test_prefattach_in
    
  end
  
  def test_prefattach_out
    
  end
  
  def test_mutual_adamic
    
  end
  
  def test_mutual_abs_in
    
  end
  
  def test_mutual_abs_out
    
  end
  
  def test_mutual_jaccard_in
    
  end
  
  def test_mutual_jaccard_out
    
  end

end