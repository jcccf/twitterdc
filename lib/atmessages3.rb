require 'set'
require 'stringio'
require 'csv'
require_relative 'forestlib/adj_graph'
require_relative 'forestlib/plotter'
require_relative 'forestlib/counter'
require_relative 'forestlib/processor'
require_relative 'forestlib/disjoint_set'
require_relative 'forestlib/decision_tree'
require_relative 'twitterdc/constants'
require_relative 'atmessages2'
include ForestLib
include TwitterDc

class AtMessages3
  
  def initialize(source_filename,base_dir,n,k1,k2,e1,e2,st)
    @c = Constants.new base_dir, n, k1, k2, e1, e2, st
    @a2 = AtMessages2.new(source_filename,base_dir,n,k1,k2,e1,e2,st)
  end
  
  # Generate CSV input files for decision tree based on some classification criteria
  def generate_csv_files(i)
    label_array = []
    label_array << 'indegree_ratio'
    label_array << 'outdegree_ratio'
    label_array << 'outindegree_ratio'
    label_array << 'inmsg_ratio'
    label_array << 'outmsg_ratio'
    label_array << 'mutualin_nbrs_ratio'
    label_array << 'reciprocated'
    
    # Get edges and equal amounts of reciprocated and unreciprocated edges
    puts "Getting edges..."
    edges = @a2.read_rur_edges(@c.unreciprocated(i), @c.reciprocated_norep(i)).sort_by{rand}
    #puts edges.inspect
    
    # Classify edges
    puts "Classifying..."
    p_degrees = Processor.to_hash_float(@c.degrees) # In-degree of each edge
    p_outdegrees = Processor.to_hash_float(@c.degrees, 0, 2) # Out-degree of each edge
    p_inoutdegrees = Processor.to_hash_float_block(@c.degrees, 0, 1, 2) { |indeg,outdeg| outdeg/indeg } # Out-degree/In-degree of each node
    p_inmsgs = Processor.to_hash_float(@c.people_msg, 0, 1) # In-message count of each edge
    p_outmsgs = Processor.to_hash_float(@c.people_msg, 0, 2) # Out-message count of each edge
    p_edges = Processor.to_hash_array(@c.edges, 1, 0) # List of in-neighbors
    data = []
    edges.each do |e1,e2,type|
      degree_ratio = (p_degrees[e1] && p_degrees[e2]) ? p_degrees[e1]/p_degrees[e2] : 0.0
      degree_classifier = classify(degree_ratio)
      
      outdegree_ratio = (p_outdegrees[e1] && p_outdegrees[e2]) ? p_outdegrees[e1]/p_outdegrees[e2] : 0.0
      outdegree_classifier = classify(outdegree_ratio)
      
      inoutdegree_ratio = (p_inoutdegrees[e1] && p_inoutdegrees[e2]) ? p_inoutdegrees[e1]/p_inoutdegrees[e2] : 0.0
      inoutdegree_classifier = classify(inoutdegree_ratio)
      
      inmsg_ratio = (p_inmsgs[e1] && p_inmsgs[e2]) ? p_inmsgs[e1]/p_inmsgs[e2] : 0.0
      inmsg_classifier = classify(inmsg_ratio)
      
      outmsg_ratio = (p_outmsgs[e1] && p_outmsgs[e2]) ? p_outmsgs[e1]/p_outmsgs[e2] : 0.0
      outmsg_classifier = classify(outmsg_ratio)
      
      num_mutual = (p_edges[e1] && p_edges[e2]) ? (p_edges[e1] & p_edges[e2]).size : 0
      total_nbrs = ((p_edges[e1] ? p_edges[e1] : []) | (p_edges[e2] ? p_edges[e2] : [])).size
      mutualin_nbrs_ratio = (num_mutual-0.0) / total_nbrs
      mutualin_nbrs_classifier = classify(mutualin_nbrs_ratio, :zero_to_one)
      
      reciprocated = (type == 1) ? 'N' : 'Y'
      data << [degree_classifier, outdegree_classifier, inoutdegree_classifier, inmsg_classifier, outmsg_classifier, mutualin_nbrs_classifier, reciprocated]
    end
    
    # Separate into training and test
    puts "Separating and printing..."
    training_data = data[0..(edges.count/2 - 1)] # Split into 2
    test_data = data[(edges.count/2)..(edges.count - 1)]
    
    # Print training and test CSV
    to_csv(@c.csv_training(i), label_array, training_data)
    to_csv(@c.csv_test(i), label_array, test_data)
  end
  
  # Generate decision tree rules using training data and test against test data
  def decision_tree_generate(i)
    #Generate
    puts "Generating rules based on training data..."
    @dt = DecisionTree.new(@c.csv_training(i))
    File.open(@c.decision_rules(i),"w") do |f|
      f.puts @dt.get_rules
    end
    
    # Test
    puts "Testing data on generated rules..."
    data = CSV.read(@c.csv_test(i))
    data.shift
    correct, count, unmatched = 0, 0, []
    data.each do |d|
      puts d[0..-2].inspect
      puts d[-1].inspect
      begin
        correct += 1 if @dt.eval(d[0..-2]) == d[-1]
      rescue NameError
        unmatched << d
      end
      count += 1
    end
    File.open(@c.decision_results(i),"w") do |f|
      f.puts "Accuracy: %d %d %.4f" % [correct, count, (correct-0.0)/count]
      f.puts "Unmatched: "
      unmatched.each { |u| f.puts u.inspect }
    end
  end
  
  # Test rules generated for i on j
  def decision_tree_evaluate(i,j)
    rules = IO.read(@c.decision_rules(i))
    data = CSV.read(@c.csv_test(j))
    data.shift
    correct, count, unmatched = 0,0,[]
    data.each do |d|
      puts d[0..-2].inspect
      puts d[-1].inspect
      indegree_ratio, outdegree_ratio, outindegree_ratio = d[0], d[1], d[2]
      inmsg_ratio, outmsg_ratio, mutualin_nbrs_ratio = d[3], d[4], d[5]
      reciprocated = nil
      eval(rules)
      begin
        correct += 1 if reciprocated == d[-1]
      rescue
        unmatched << d
      end
      count += 1
    end
    
    File.open(@c.decision_results_bon(i,j),"w") do |f|
      f.puts "Using rules of %d on %j" % [i,j]
      f.puts "XAccuracy: %d %d %.4f" % [correct, count, (correct-0.0)/count]
      f.puts "Unmatched: "
      unmatched.each { |u| f.puts u.inspect }
    end
  end
  
  private
  
  # Classify continuous numbers (ratios) into discrete values
  def classify(ratio, type = :e_to_e_inverse)
    case type
    when :e_to_e_inverse
      (0..10).each do |i|
        e = 1 - i/10.0
        if e <= ratio && ratio <= 1/e
          return sprintf("%.1f", e)
        end
      end
    when :zero_to_one
      (0..10).each do |i|
        e = 1 - i/10.0
        if ratio >= e
          return sprintf("%.1f", e)
        end
      end
    else
      raise ArgumentException, "Invalid type passed to classify"
    end
    raise RuntimeException, "Not supposed to get here"
  end
  
  # Save a CSV file based on the input arrays
  def to_csv(filename, label_array, data_array)
    CSV.open(filename, "wb") do |csv|
      csv << label_array
      data_array.each { |d| csv << d }
    end
  end
  
end