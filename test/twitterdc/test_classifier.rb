require "test/unit"
require "stringio"
require_relative "../../lib/twitterdc/classifier"
include TwitterDc
 
class TestTwitterDcClassifier < Test::Unit::TestCase
  
  def setup
  end
  
  def teardown
  end
  
  def test_one_variable
    x = ReciprocityHeuristics::Classifier.new
    x.percentiles(:hello, {"a" => 3, "b" => 2, "c" => 1})
    assert_equal(x.classified, {"c"=>{:hello=>40}, "b"=>{:hello=>70}, "a"=>{:hello=>100}})
  end
  
  def test_two_variables
    x = ReciprocityHeuristics::Classifier.new
    x.percentiles(:hello, {"a" => 3, "b" => 2, "c" => 1})
    x.percentiles("bye", {"b" => 1, "c" => 2, "a" => 3})
    assert_equal(x.classified, {"c"=>{:hello=>40, "bye"=>70}, "b"=>{:hello=>70, "bye"=>40}, "a"=>{:hello=>100, "bye"=>100}})
  end
  
  def test_weird_keys
    x = ReciprocityHeuristics::Classifier.new
    x.percentiles(:hello, {{1=>2} => 3, {2=>1} => 2, {3=>1} => 1})
    assert_equal(x.classified, {{3=>1}=>{:hello=>40}, {2=>1}=>{:hello=>70}, {1=>2}=>{:hello=>100}})
  end
  
  def test_float_values
    x = ReciprocityHeuristics::Classifier.new
    x.percentiles(:hello, {"a" => 0.005, "b" => 0.0, "c" => -2.2})
    puts x.classified
    assert_equal(x.classified, {"c"=>{:hello=>40}, "b"=>{:hello=>70}, "a"=>{:hello=>100}})
  end
  
end