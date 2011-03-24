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
    label_array = [ 'degree_ratio', 'inmsg_ratio', 'reciprocated' ] # TODO - DegMsg, Mutual
    
    # Get edges and equal amounts of reciprocated and unreciprocated edges
    edges = @a2.read_rur_edges(@c.unreciprocated(i), @c.reciprocated_norep(i)).sort_by{rand}
    puts edges.inspect
    
    # Classify edges
    p_degrees = Processor.to_hash_float(@c.degrees) # Degree of each edge
    p_inmsgs = Processor.to_hash_float(@c.people_msg, 0, 1) # In-message count of each edge
    p_edges = Processor.to_hash_array(@c.edges, 1, 0) # List of in-neighbors
    data = []
    edges.each do |e1,e2,type|
      degree_ratio = (p_degrees[e1] && p_degrees[e2]) ? p_degrees[e1]/p_degrees[e2] : 0.0
      degree_classifier = classify(degree_ratio)
      inmsg_ratio = (p_inmsgs[e1] && p_inmsgs[e2]) ? p_inmsgs[e1]/p_inmsgs[e2] : 0.0
      inmsg_classifier = classify(inmsg_ratio)
      reciprocated = (type == 1) ? 'N' : 'Y'
      data << [degree_classifier, inmsg_classifier, reciprocated]
    end
    
    # Separate into training and test
    training_data = data[0..(edges.count/2 - 1)] # Split into 2
    test_data = data[(edges.count/2)..(edges.count - 1)]
    
    # Print training and test CSV
    to_csv(@c.csv_training(i), label_array, training_data)
    to_csv(@c.csv_test(i), label_array, test_data)
  end
  
  def decision_tree_generate(i)
    @dt = DecisionTree.new(@c.csv_training(i))
    puts @dt.get_rules
  end
  
  def decision_tree_test
    # Read in rules from file
    
    # Test
    
    # Output accuracy
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
      raise ArgumentException, "Invalid For Now"
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