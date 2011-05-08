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
    
end