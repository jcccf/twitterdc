require 'set'
require 'stringio'
require 'csv'
require_relative 'forestlib/forestlib'
require_relative 'twitterdc/twitterdc'
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
    label_array << 'adamic'
    label_array << 'katz'
    #label_array << 'pagerank'
    label_array << 'prefattach'
    label_array << 'reciprocated'
    
    # Get edges and all reciprocated and unreciprocated edges
    puts "Getting ALL edges..."
    edges = ReciprocityHeuristics::Helpers.read_rur_edges(@c.unreciprocated(i), @c.reciprocated_norep(i), false).sort_by{rand}
    #puts edges.inspect
    
    # Classify edges
    puts "Classifying..."
    p_degrees = Processor.to_hash_float(@c.degrees) # In-degree of each edge
    p_outdegrees = Processor.to_hash_float(@c.degrees, 0, 2) # Out-degree of each edge
    p_inoutdegrees = Processor.to_hash_float_block(@c.degrees, 0, 1, 2) { |indeg,outdeg| outdeg/indeg } # Out-degree/In-degree of each node
    p_inmsgs = Processor.to_hash_float(@c.people_msg, 0, 1) # In-message count of each edge
    p_outmsgs = Processor.to_hash_float(@c.people_msg, 0, 2) # Out-message count of each edge
    p_edges = Processor.to_hash_array(@c.edges, 1, 0) # List of in-neighbors
    p_outedges = Processor.to_hash_array(@c.edges, 0, 1)
    p_undirected_edges = Processor.to_hash_array(@c.edges, 0, 1, false)
    p_adamic = ReciprocityHeuristics::MutualInAdamicDecision.new(@c,p_outdegrees,p_edges)
    p_katz = ReciprocityHeuristics::KatzNStepDecision.new(@c,p_outedges)
    #p_pagerank = ReciprocityHeuristics::RootedPagerankDecision.new(@c,p_undirected_edges)
    p_pref = ReciprocityHeuristics::PreferentialAttachmentDecision.new(@c,p_degrees)
    data = []
    
    # Precomputation for percentiles
    puts "Running precomputation..."
    pclassifier = ReciprocityHeuristics::Classifier.new
    degree_ratios, outdegree_ratios, inoutdegree_ratios = {}, {}, {}
    inmsg_ratios, outmsg_ratios = {}, {}
    mutualin_nbrs_ratios, katz_paths, adamics, prefattaches = {}, {}, {}, {}
    edges.each do |e1,e2,type|
      dr = (p_degrees[e1] && p_degrees[e2]) ? p_degrees[e1]/p_degrees[e2] : 0.0
      degree_ratios[[e1,e2]] = dr > 1 ? 1.0/dr : dr
      
      odr = (p_outdegrees[e1] && p_outdegrees[e2]) ? p_outdegrees[e1]/p_outdegrees[e2] : 0.0
      outdegree_ratios[[e1,e2]] = odr > 1 ? 1.0/odr : odr
      
      iod = (p_inoutdegrees[e1] && p_inoutdegrees[e2]) ? p_inoutdegrees[e1]/p_inoutdegrees[e2] : 0.0
      inoutdegree_ratios[[e1,e2]] = iod > 1 ? 1.0/iod : iod
      
      im = (p_inmsgs[e1] && p_inmsgs[e2]) ? p_inmsgs[e1]/p_inmsgs[e2] : 0.0
      inmsg_ratios[[e1,e2]] = im > 1 ? 1.0/im : im
      
      om = (p_outmsgs[e1] && p_outmsgs[e2]) ? p_outmsgs[e1]/p_outmsgs[e2] : 0.0
      outmsg_ratios[[e1,e2]] = om > 1 ? 1.0/om : om
      
      num_mutual = (p_edges[e1] && p_edges[e2]) ? (p_edges[e1] & p_edges[e2]).size : 0
      total_nbrs = ((p_edges[e1] ? p_edges[e1] : []) | (p_edges[e2] ? p_edges[e2] : [])).size
      mn = (num_mutual-0.0) / total_nbrs
      mutualin_nbrs_ratios[[e1,e2]] = mn > 1 ? 1.0/mn : mn
      
      adamics[[e1,e2]] = p_adamic.result(e1,e2)
      katz_paths[[e1,e2]] = p_katz.result(e1,e2)
      
      prefattaches[[e1,e2]] = p_pref.result(e1,e2)
    end
    
    p_degrees = nil
    p_outdegrees = nil
    p_inoutdegrees = nil
    p_inmsgs = nil
    p_outmsgs = nil
    p_edges = nil
    p_outedges = nil
    p_undirected_edges = nil
    p_adamic = nil
    p_katz = nil
    p_pref = nil
    
    GC.start
    
    pclassifier.percentiles(:degree, degree_ratios)
    degree_ratios = nil
    pclassifier.percentiles(:outdegree, outdegree_ratios)
    outdegree_ratios = nil
    pclassifier.percentiles(:inoutdegree, inoutdegree_ratios)
    inoutdegree_ratios = nil
    pclassifier.percentiles(:inmsg, inmsg_ratios)
    inmsg_ratios = nil
    pclassifier.percentiles(:outmsg, outmsg_ratios)
    outmsg_ratios = nil
    pclassifier.percentiles(:mutualin_nbrs, mutualin_nbrs_ratios)
    mutualin_nbrs_ratios = nil
    pclassifier.percentiles(:adamic, adamics)
    adamics = nil
    pclassifier.percentiles(:katz, katz_paths)
    katz_paths = nil
    pclassifier.percentiles(:prefattach, prefattaches)
    pref_attaches = nil
    
    GC.start
    
    # Regular computation
    j = 0
    halfway = edges.count/2 - 1
    CSV.open(Constant.new(@c,"csv_test").filename(i)+"~", "w") do |csv_test|
      CSV.open(Constant.new(@c,"csv_training").filename(i)+"~", "w") do |csv|
        csv << label_array
        csv_test << label_array
        
        puts "Running regular computation..."
        edges.each do |e1,e2,type|
          # degree_ratio = (p_degrees[e1] && p_degrees[e2]) ? p_degrees[e1]/p_degrees[e2] : 0.0
          # degree_classifier = ReciprocityHeuristics::Classifier.e_to_e_inverse(degree_ratio)
          # 
          # outdegree_ratio = (p_outdegrees[e1] && p_outdegrees[e2]) ? p_outdegrees[e1]/p_outdegrees[e2] : 0.0
          # outdegree_classifier = ReciprocityHeuristics::Classifier.e_to_e_inverse(outdegree_ratio)
          # 
          # inoutdegree_ratio = (p_inoutdegrees[e1] && p_inoutdegrees[e2]) ? p_inoutdegrees[e1]/p_inoutdegrees[e2] : 0.0
          # inoutdegree_classifier = ReciprocityHeuristics::Classifier.e_to_e_inverse(inoutdegree_ratio)
          # 
          # inmsg_ratio = (p_inmsgs[e1] && p_inmsgs[e2]) ? p_inmsgs[e1]/p_inmsgs[e2] : 0.0
          # inmsg_classifier = ReciprocityHeuristics::Classifier.e_to_e_inverse(inmsg_ratio)
          # 
          # outmsg_ratio = (p_outmsgs[e1] && p_outmsgs[e2]) ? p_outmsgs[e1]/p_outmsgs[e2] : 0.0
          # outmsg_classifier = ReciprocityHeuristics::Classifier.e_to_e_inverse(outmsg_ratio)
          # 
          # num_mutual = (p_edges[e1] && p_edges[e2]) ? (p_edges[e1] & p_edges[e2]).size : 0
          # total_nbrs = ((p_edges[e1] ? p_edges[e1] : []) | (p_edges[e2] ? p_edges[e2] : [])).size
          # mutualin_nbrs_ratio = (num_mutual-0.0) / total_nbrs
          # mutualin_nbrs_classifier = ReciprocityHeuristics::Classifier.zero_to_one(mutualin_nbrs_ratio)
          # 
          #adamic_score = p_adamic.result(e1,e2)
          #adamic_classifier = ReciprocityHeuristics::Classifier.zero_to_hundred(adamic_score)

          edge = pclassifier.classified[[e1,e2]]
          degree_classifier = edge[:degree]
          outdegree_classifier = edge[:outdegree]
          inoutdegree_classifier = edge[:inoutdegree]
          inmsg_classifier = edge[:inmsg]
          outmsg_classifier = edge[:outmsg]
          mutualin_nbrs_classifier = edge[:mutualin_nbrs]
          adamic_classifier = edge[:adamic]
          katz_classifier = edge[:katz]
          pref_classifier = edge[:prefattach]

          #pagerank_weight = p_pagerank.result(e1,e2)
          #pagerank_classifier = ReciprocityHeuristics::Classifier.zero_to_one(pagerank_weight)

          reciprocated = (type == 1) ? 'N' : 'Y'
          row = [degree_classifier, outdegree_classifier, inoutdegree_classifier, inmsg_classifier, outmsg_classifier, mutualin_nbrs_classifier, adamic_classifier, katz_classifier, pref_classifier, reciprocated]
          (j <= halfway) ? csv << row : csv_test << row
          j += 1
        end
      end
    end
    
    File.rename(Constant.new(@c,"csv_test").filename(i)+"~",Constant.new(@c,"csv_test").filename(i))
    File.rename(Constant.new(@c,"csv_training").filename(i)+"~",Constant.new(@c,"csv_training").filename(i))
    
    # # Separate into training and test
    # puts "Separating and printing..."
    # training_data = data[0..(edges.count/2 - 1)] # Split into 2
    # test_data = data[(edges.count/2)..(edges.count - 1)]
    
    # Print training and test CSV
    # to_csv(Constant.new(@c,"csv_training").filename(i), label_array, training_data)
    # to_csv(Constant.new(@c,"csv_test").filename(i), label_array, test_data)
    File.open(Constant.new(@c,"csv_transitions").filename(i),"w") do |f|
      pclassifier.print_transitions(f)
    end
  end
  
  # Generate CSV input files for decision tree based on some classification criteria
  def generate_csv_files_for_simple(i)
    label_array = []
    label_array << 'indegree_ratio'
    label_array << 'outdegree_ratio'
    label_array << 'outindegree_ratio'
    label_array << 'inmsg_ratio'
    label_array << 'outmsg_ratio'
    
    # Get edges and all reciprocated and unreciprocated edges
    puts "Getting ALL edges..."
    edges = ReciprocityHeuristics::Helpers.read_rur_edges(@c.unreciprocated(i), @c.reciprocated_norep(i), false).sort_by{rand}
    #puts edges.inspect
    
    # Classify edges
    puts "Classifying..."
    p_degrees = Processor.to_hash_float(@c.degrees) # In-degree of each edge
    p_outdegrees = Processor.to_hash_float(@c.degrees, 0, 2) # Out-degree of each edge
    p_inoutdegrees = Processor.to_hash_float_block(@c.degrees, 0, 1, 2) { |indeg,outdeg| outdeg/indeg } # Out-degree/In-degree of each node
    p_inmsgs = Processor.to_hash_float(@c.people_msg, 0, 1) # In-message count of each edge
    p_outmsgs = Processor.to_hash_float(@c.people_msg, 0, 2) # Out-message count of each edge
    data = []
    
    # Precomputation for percentiles
    puts "Running precomputation..."
    pclassifier = ReciprocityHeuristics::Classifier.new
    degree_ratios, outdegree_ratios, inoutdegree_ratios = {}, {}, {}
    inmsg_ratios, outmsg_ratios = {}, {}
    mutualin_nbrs_ratios, katz_paths, adamics, prefattaches = {}, {}, {}, {}
    edges.each do |e1,e2,type|
      dr = (p_degrees[e1] && p_degrees[e2]) ? p_degrees[e1]/p_degrees[e2] : 0.0
      degree_ratios[[e1,e2]] = dr > 1 ? 1.0/dr : dr
      
      odr = (p_outdegrees[e1] && p_outdegrees[e2]) ? p_outdegrees[e1]/p_outdegrees[e2] : 0.0
      outdegree_ratios[[e1,e2]] = odr > 1 ? 1.0/odr : odr
      
      iod = (p_inoutdegrees[e1] && p_inoutdegrees[e2]) ? p_inoutdegrees[e1]/p_inoutdegrees[e2] : 0.0
      inoutdegree_ratios[[e1,e2]] = iod > 1 ? 1.0/iod : iod
      
      im = (p_inmsgs[e1] && p_inmsgs[e2]) ? p_inmsgs[e1]/p_inmsgs[e2] : 0.0
      inmsg_ratios[[e1,e2]] = im > 1 ? 1.0/im : im
      
      om = (p_outmsgs[e1] && p_outmsgs[e2]) ? p_outmsgs[e1]/p_outmsgs[e2] : 0.0
      outmsg_ratios[[e1,e2]] = om > 1 ? 1.0/om : om
    end
    
    p_degrees = nil
    p_outdegrees = nil
    p_inoutdegrees = nil
    p_inmsgs = nil
    p_outmsgs = nil
    
    GC.start
    
    pclassifier.percentiles(:degree, degree_ratios)
    degree_ratios = nil
    pclassifier.percentiles(:outdegree, outdegree_ratios)
    outdegree_ratios = nil
    pclassifier.percentiles(:inoutdegree, inoutdegree_ratios)
    inoutdegree_ratios = nil
    pclassifier.percentiles(:inmsg, inmsg_ratios)
    inmsg_ratios = nil
    pclassifier.percentiles(:outmsg, outmsg_ratios)
    outmsg_ratios = nil
    
    GC.start
    
    # Regular computation
    j = 0
    halfway = edges.count/2 - 1
    CSV.open(Constant.new(@c,"csv_test_simple").filename(i)+"~", "w") do |csv_test|
      CSV.open(Constant.new(@c,"csv_training_simple").filename(i)+"~", "w") do |csv|
        csv << label_array
        csv_test << label_array
        
        puts "Running regular computation..."
        edges.each do |e1,e2,type|
          # degree_ratio = (p_degrees[e1] && p_degrees[e2]) ? p_degrees[e1]/p_degrees[e2] : 0.0
          # degree_classifier = ReciprocityHeuristics::Classifier.e_to_e_inverse(degree_ratio)
          # 
          # outdegree_ratio = (p_outdegrees[e1] && p_outdegrees[e2]) ? p_outdegrees[e1]/p_outdegrees[e2] : 0.0
          # outdegree_classifier = ReciprocityHeuristics::Classifier.e_to_e_inverse(outdegree_ratio)
          # 
          # inoutdegree_ratio = (p_inoutdegrees[e1] && p_inoutdegrees[e2]) ? p_inoutdegrees[e1]/p_inoutdegrees[e2] : 0.0
          # inoutdegree_classifier = ReciprocityHeuristics::Classifier.e_to_e_inverse(inoutdegree_ratio)
          # 
          # inmsg_ratio = (p_inmsgs[e1] && p_inmsgs[e2]) ? p_inmsgs[e1]/p_inmsgs[e2] : 0.0
          # inmsg_classifier = ReciprocityHeuristics::Classifier.e_to_e_inverse(inmsg_ratio)
          # 
          # outmsg_ratio = (p_outmsgs[e1] && p_outmsgs[e2]) ? p_outmsgs[e1]/p_outmsgs[e2] : 0.0
          # outmsg_classifier = ReciprocityHeuristics::Classifier.e_to_e_inverse(outmsg_ratio)
          # 
          # num_mutual = (p_edges[e1] && p_edges[e2]) ? (p_edges[e1] & p_edges[e2]).size : 0
          # total_nbrs = ((p_edges[e1] ? p_edges[e1] : []) | (p_edges[e2] ? p_edges[e2] : [])).size
          # mutualin_nbrs_ratio = (num_mutual-0.0) / total_nbrs
          # mutualin_nbrs_classifier = ReciprocityHeuristics::Classifier.zero_to_one(mutualin_nbrs_ratio)
          # 
          #adamic_score = p_adamic.result(e1,e2)
          #adamic_classifier = ReciprocityHeuristics::Classifier.zero_to_hundred(adamic_score)

          edge = pclassifier.classified[[e1,e2]]
          degree_classifier = edge[:degree]
          outdegree_classifier = edge[:outdegree]
          inoutdegree_classifier = edge[:inoutdegree]
          inmsg_classifier = edge[:inmsg]
          outmsg_classifier = edge[:outmsg]

          #pagerank_weight = p_pagerank.result(e1,e2)
          #pagerank_classifier = ReciprocityHeuristics::Classifier.zero_to_one(pagerank_weight)

          reciprocated = (type == 1) ? 'N' : 'Y'
          row = [degree_classifier, outdegree_classifier, inoutdegree_classifier, inmsg_classifier, outmsg_classifier, reciprocated]
          (j <= halfway) ? csv << row : csv_test << row
          j += 1
        end
      end
    end
    
    File.rename(Constant.new(@c,"csv_test_simple").filename(i)+"~",Constant.new(@c,"csv_test_simple").filename(i))
    File.rename(Constant.new(@c,"csv_training_simple").filename(i)+"~",Constant.new(@c,"csv_training_simple").filename(i))
    
    # # Separate into training and test
    # puts "Separating and printing..."
    # training_data = data[0..(edges.count/2 - 1)] # Split into 2
    # test_data = data[(edges.count/2)..(edges.count - 1)]
    
    # Print training and test CSV
    # to_csv(Constant.new(@c,"csv_training").filename(i), label_array, training_data)
    # to_csv(Constant.new(@c,"csv_test").filename(i), label_array, test_data)
    File.open(Constant.new(@c,"csv_transitions_simple").filename(i),"w") do |f|
      pclassifier.print_transitions(f)
    end
  end
  
  # Generate decision tree rules using training data and test against test data
  def decision_tree_generate(i)
    #Generate
    puts "Generating rules based on training data..."
    @dt = DecisionTree.new(Constant.new(@c,"csv_training").filename(i))
    File.open(Constant.new(@c,"decision_rules").filename(i),"w") do |f|
      f.puts @dt.get_rules
    end
    
    # Test
    puts "Testing data on generated rules..."
    data = CSV.read(Constant.new(@c,"csv_test").filename(i))
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
    File.open(Constant.new(@c,"decision_results").filename(i),"w") do |f|
      f.puts "Accuracy: %d %d %.4f" % [correct, count, (correct-0.0)/count]
      f.puts "Unmatched: "
      unmatched.each { |u| f.puts u.inspect }
    end
  end
  
  # Test rules generated for i on j
  def decision_tree_evaluate(i,j)
    rules = IO.read(Constant.new(@c,"decision_rules").filename(i))
    data = CSV.read(Constant.new(@c,"csv_test").filename(j))
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
    
    File.open(Constant.new(@c,"decision_results_basedon",[i]).filename(j),"w") do |f|
      f.puts "Using rules of %d on %j" % [i,j]
      f.puts "XAccuracy: %d %d %.4f" % [correct, count, (correct-0.0)/count]
      f.puts "Unmatched: "
      unmatched.each { |u| f.puts u.inspect }
    end
  end
  
  private
  
  # Save a CSV file based on the input arrays
  def to_csv(filename, label_array, data_array)
    CSV.open(filename, "wb") do |csv|
      csv << label_array
      data_array.each { |d| csv << d }
    end
  end
  
end