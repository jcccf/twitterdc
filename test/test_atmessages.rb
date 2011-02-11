require "test/unit"
require "stringio"
require_relative "../lib/atmessages"
 
class TestAtMessages < Test::Unit::TestCase
  
  def setup
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
    AtMessages.filter_users_by_messages("data/test2.dat","tmp.dat",0)
    assert_file_equal("10 4\n15 2\n14 3\n16 1\n","tmp.dat")
  end
  
  def test_filter_users_by_messages_1
    AtMessages.filter_users_by_messages("data/test2.dat","tmp.dat",1)
    assert_file_equal("10 4\n15 2\n14 3\n16 1\n","tmp.dat")
  end
  
  def test_filter_users_by_messages_3
    AtMessages.filter_users_by_messages("data/test2.dat","tmp.dat",3)
    assert_file_equal("10 4\n14 3\n","tmp.dat")
  end
  
  def test_filter_users_by_messages_max
    AtMessages.filter_users_by_messages("data/test2.dat","tmp.dat",5)
    assert_file_equal(nil,"tmp.dat")
  end
  
  def test_filter_graph_by_users_1
    AtMessages.filter_graph_by_users("data/test2.dat","data/atmessages_people.dat","tmp.dat")
    assert_file_equal("15\t20\t1\t3\n14\t20\t1\t5\n14\t16\t1\t7\n15\t10\t1\t9\n14\t15\t1\t10\n","tmp.dat")
  end
  
end