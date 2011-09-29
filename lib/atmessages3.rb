require 'set'
require 'stringio'
require 'csv'
require 'yaml'
require_relative 'forestlib/forestlib'
require_relative 'twitterdc/twitterdc'
require_relative 'atmessages2'
include ForestLib
include TwitterDc

class AtMessages3
  
  def initialize(source_filename,base_dir,n,k1,k2,e1,e2,st)
    @c = Constants.new base_dir, n, k1, k2, e1, e2, st
    @a2 = AtMessages2.new(source_filename,base_dir,n,k1,k2,e1,e2,st)
    #@edges = []
  end
  
  # def setedges
  #   @edges = ReciprocityHeuristics::Helpers.read_rur_edges(@c.unreciprocated(3), @c.reciprocated_norep(3), false).sort_by{rand}
  # end
  
  def get_edges(i,balanced=false)
    edge_file = balanced ? @c.decision_edges_balanced(i) : @c.decision_edges(i)
    if File.exist?(edge_file)
      edges = nil
      File.open(edge_file,"r") do |f|
        edges = YAML::load(f)
      end
      raise "File is empty???" if edges == nil
      edges
    else
      edges = ReciprocityHeuristics::Helpers.read_rur_edges(@c.unreciprocated(i), @c.reciprocated_norep(i), balanced).sort_by{rand}
      File.open(edge_file,"w") do |f|
        f.puts edges.to_yaml
      end
      edges
    end
  end
  
  def get_edges_with_filter(i,filter_name)
    uf, rf = Constant.new(@c,"unr_"+filter_name.to_s).filename(i), Constant.new(@c,"rec_"+filter_name.to_s).filename(i)
    dec_edges = @c.decision_edges_filter(filter_name.to_s,i)
    if File.exist?(dec_edges)
      edges = nil
      File.open(dec_edges,"r") do |f|
        edges = YAML::load(f)
      end
      raise "File is empty???" if edges == nil
      edges
    else
      edges = ReciprocityHeuristics::Helpers.read_rur_edges(uf, rf, true).sort_by{rand} # Get balanced
      File.open(dec_edges,"w") do |f|
        f.puts edges.to_yaml
      end
      edges
    end
  end
  
  def generate_csv_files_vw(i,balanced=false)
    edges = get_edges(i,balanced)
    p_degrees = Processor.to_hash_float(@c.degrees) # In-degree of each edge
    p_outdegrees = Processor.to_hash_float(@c.degrees, 0, 2) # Out-degree of each edge
    p_inoutdegrees = Processor.to_hash_float_block(@c.degrees, 0, 1, 2) { |indeg,outdeg| outdeg/indeg } # Out-degree/In-degree of each node
    p_inmsgs = Processor.to_hash_float(@c.people_msg, 0, 1) # In-message count of each edge
    p_outmsgs = Processor.to_hash_float(@c.people_msg, 0, 2) # Out-message count of each edge
    p_msgedges = Processor.to_tuple_hash_float(@c.rur_msg_edges(@c.k))
    
    name = balanced ? "vw_bal" : "vw"
    dtp = dtp = DecisionTreePreprocessor.new(@c, i, name, edges)
    dtp.percentiles_for_v(:indegree_v,ReciprocityHeuristics::DegreeDecision.new(@c,p_degrees,:in))
    dtp.percentiles_for_v(:outdegree_v,ReciprocityHeuristics::DegreeDecision.new(@c,p_outdegrees,:out))
    dtp.percentiles_for_v(:inoutdegree_v,ReciprocityHeuristics::OutdegreePerIndegreeDecision.new(@c,p_degrees,p_outdegrees))
    dtp.percentiles_for_v(:inmessage_v,ReciprocityHeuristics::MessagesDecision.new(@c,p_inmsgs,p_msgedges,:in))
    dtp.percentiles_for_v(:outmessage_v,ReciprocityHeuristics::MessagesDecision.new(@c,p_outmsgs,p_msgedges,:out))
    dtp.percentiles_for_v(:inmsgdeg_v,ReciprocityHeuristics::MessagesPerDegreeDecision.new(@c,p_inmsgs,p_degrees,p_msgedges,:in))
    dtp.percentiles_for_v(:outmsgdeg_v,ReciprocityHeuristics::MessagesPerDegreeDecision.new(@c,p_outmsgs,p_outdegrees,p_msgedges,:out))
    dtp.percentiles_for_w(:indegree_w,ReciprocityHeuristics::DegreeDecision.new(@c,p_degrees,:in))
    dtp.percentiles_for_w(:outdegree_w,ReciprocityHeuristics::DegreeDecision.new(@c,p_outdegrees,:out))
    dtp.percentiles_for_w(:inoutdegree_w,ReciprocityHeuristics::OutdegreePerIndegreeDecision.new(@c,p_degrees,p_outdegrees))
    dtp.percentiles_for_w(:inmessage_w,ReciprocityHeuristics::MessagesDecision.new(@c,p_inmsgs,p_msgedges,:in))
    dtp.percentiles_for_w(:outmessage_w,ReciprocityHeuristics::MessagesDecision.new(@c,p_outmsgs,p_msgedges,:out))
    dtp.percentiles_for_w(:inmsgdeg_w,ReciprocityHeuristics::MessagesPerDegreeDecision.new(@c,p_inmsgs,p_degrees,p_msgedges,:in))
    dtp.percentiles_for_w(:outmsgdeg_w,ReciprocityHeuristics::MessagesPerDegreeDecision.new(@c,p_outmsgs,p_outdegrees,p_msgedges,:out))
    dtp.output
  end
  
  def generate_csv_files_simple(i,balanced=false)
    edges = get_edges(i,balanced)
    #edges = @edges
    p_degrees = Processor.to_hash_float(@c.degrees) # In-degree of each edge
    p_outdegrees = Processor.to_hash_float(@c.degrees, 0, 2) # Out-degree of each edge
    p_inoutdegrees = Processor.to_hash_float_block(@c.degrees, 0, 1, 2) { |indeg,outdeg| outdeg/indeg } # Out-degree/In-degree of each node
    p_inmsgs = Processor.to_hash_float(@c.people_msg, 0, 1) # In-message count of each edge
    p_outmsgs = Processor.to_hash_float(@c.people_msg, 0, 2) # Out-message count of each edge
    p_msgedges = Processor.to_tuple_hash_float(@c.rur_msg_edges(@c.k))
    
    name = balanced ? "simple_bal" : "simple"
    dtp = DecisionTreePreprocessor.new(@c, i, name, edges)
    dtp.percentiles_for(:indegree,ReciprocityHeuristics::DegreeDecision.new(@c,p_degrees,:in))
    dtp.percentiles_for(:outdegree,ReciprocityHeuristics::DegreeDecision.new(@c,p_outdegrees,:out))
    dtp.percentiles_for(:inoutdegree,ReciprocityHeuristics::OutdegreePerIndegreeDecision.new(@c,p_degrees,p_outdegrees))
    dtp.percentiles_for(:inmessage,ReciprocityHeuristics::MessagesDecision.new(@c,p_inmsgs,p_msgedges,:in))
    dtp.percentiles_for(:outmessage,ReciprocityHeuristics::MessagesDecision.new(@c,p_outmsgs,p_msgedges,:out))
    dtp.percentiles_for(:inmsgdeg,ReciprocityHeuristics::MessagesPerDegreeDecision.new(@c,p_inmsgs,p_degrees,p_msgedges,:in))
    dtp.percentiles_for(:outmsgdeg,ReciprocityHeuristics::MessagesPerDegreeDecision.new(@c,p_outmsgs,p_outdegrees,p_msgedges,:out))
    dtp.output    
  end
  
  def generate_csv_files_paths(i,balanced=false)
    edges = get_edges(i,balanced)
    p_edges = Processor.to_hash_array(@c.edges, 1, 0) # List of in-neighbors
    p_outedges = Processor.to_hash_array(@c.edges, 0, 1)
    
    name = balanced ? "paths_bal" : "paths"
    dtp = DecisionTreePreprocessor.new(@c, i, name, edges)
    dtp.percentiles_for(:mutual_abs_in,ReciprocityHeuristics::MutualAbsoluteDecision.new(@c,p_edges,:in))
    dtp.percentiles_for(:mutual_abs_out,ReciprocityHeuristics::MutualAbsoluteDecision.new(@c,p_outedges,:out))
    dtp.percentiles_for_sym(:katz_a_b, ReciprocityHeuristics::KatzNStepDirectedDecision.new(@c,p_outedges))
    dtp.percentiles_for_sym(:katz_b_a, ReciprocityHeuristics::KatzNStepDirectedDecision.new(@c,p_edges))
    dtp.output
  end
  
  def generate_csv_files_link(i,balanced=false)
    edges = get_edges(i,balanced)
    p_degrees = Processor.to_hash_float(@c.degrees) # In-degree of each edge
    p_outdegrees = Processor.to_hash_float(@c.degrees, 0, 2) # Out-degree of each edge
    p_edges = Processor.to_hash_array(@c.edges, 1, 0) # List of in-neighbors
    p_outedges = Processor.to_hash_array(@c.edges, 0, 1)
    
    name = balanced ? "link_bal" : "link"
    dtp = DecisionTreePreprocessor.new(@c, i, name, edges)
    dtp.percentiles_for(:katz_out,ReciprocityHeuristics::KatzNStepDecision.new(@c,p_outedges))
    dtp.percentiles_for(:jaccard_in,ReciprocityHeuristics::MutualJaccardDecision.new(@c,p_edges,:in))
    dtp.percentiles_for(:jaccard_out,ReciprocityHeuristics::MutualJaccardDecision.new(@c,p_edges,:out))
    dtp.percentiles_for(:adamic,ReciprocityHeuristics::MutualInAdamicDecision.new(@c,p_outdegrees,p_edges))
    dtp.percentiles_for(:prefattach_vw,ReciprocityHeuristics::PreferentialAttachmentDecision.new(@c,p_degrees,:v_to_w))
    dtp.percentiles_for(:prefattach_wv,ReciprocityHeuristics::PreferentialAttachmentDecision.new(@c,p_outdegrees,:w_to_v))
    dtp.output
  end
  
  def generate_csv_files_pref(i,balanced=false)
  	edges = get_edges(i,balanced)
    p_degrees = Processor.to_hash_float(@c.degrees) # In-degree of each edge
    p_outdegrees = Processor.to_hash_float(@c.degrees, 0, 2) # Out-degree of each edge
    
    name = balanced ? "pref_bal" : "pref"
    dtp = DecisionTreePreprocessor.new(@c, i, name, edges)
  	dtp.percentiles_for(:prefattach_vw,ReciprocityHeuristics::PreferentialAttachmentDecision.new(@c,p_degrees,:v_to_w))
    dtp.percentiles_for(:prefattach_wv,ReciprocityHeuristics::PreferentialAttachmentDecision.new(@c,p_outdegrees,:w_to_v))
    dtp.output
  end
  
  def generate_csv_files(i)
    edges = get_edges(i)
    p_degrees = Processor.to_hash_float(@c.degrees) # In-degree of each edge
    p_outdegrees = Processor.to_hash_float(@c.degrees, 0, 2) # Out-degree of each edge
    p_inoutdegrees = Processor.to_hash_float_block(@c.degrees, 0, 1, 2) { |indeg,outdeg| outdeg/indeg } # Out-degree/In-degree of each node
    p_inmsgs = Processor.to_hash_float(@c.people_msg, 0, 1) # In-message count of each edge
    p_outmsgs = Processor.to_hash_float(@c.people_msg, 0, 2) # Out-message count of each edge
    p_msgedges = Processor.to_tuple_hash_float(@c.rur_msg_edges(@c.k))
    p_edges = Processor.to_hash_array(@c.edges, 1, 0) # List of in-neighbors
    p_outedges = Processor.to_hash_array(@c.edges, 0, 1)
    #p_undirected_edges = Processor.to_hash_array(@c.edges, 0, 1, false)
    
    dtp = DecisionTreePreprocessor.new(@c, i, "all", edges)
    dtp.percentiles_for(:indegree,ReciprocityHeuristics::DegreeDecision.new(@c,p_degrees,:in))
    dtp.percentiles_for(:outdegree,ReciprocityHeuristics::DegreeDecision.new(@c,p_outdegrees,:out))
    dtp.percentiles_for(:inoutdegree,ReciprocityHeuristics::OutdegreePerIndegreeDecision.new(@c,p_degrees,p_outdegrees))
    dtp.percentiles_for(:inmessage,ReciprocityHeuristics::MessagesDecision.new(@c,p_inmsgs,p_msgedges,:in))
    dtp.percentiles_for(:outmessage,ReciprocityHeuristics::MessagesDecision.new(@c,p_outmsgs,p_msgedges,:out))
    dtp.percentiles_for(:inmsgdeg,ReciprocityHeuristics::MessagesPerDegreeDecision.new(@c,p_inmsgs,p_degrees,p_msgedges,:in))
    dtp.percentiles_for(:outmsgdeg,ReciprocityHeuristics::MessagesPerDegreeDecision.new(@c,p_outmsgs,p_outdegrees,p_msgedges,:out))
    dtp.percentiles_for(:mutual_abs_in,ReciprocityHeuristics::MutualAbsoluteDecision.new(@c,p_edges,:in))
    dtp.percentiles_for(:mutual_abs_out,ReciprocityHeuristics::MutualAbsoluteDecision.new(@c,p_outedges,:out))
    dtp.percentiles_for(:jaccard_in,ReciprocityHeuristics::MutualJaccardDecision.new(@c,p_edges,:in))
    dtp.percentiles_for(:jaccard_out,ReciprocityHeuristics::MutualJaccardDecision.new(@c,p_edges,:out))
    dtp.percentiles_for(:adamic,ReciprocityHeuristics::MutualInAdamicDecision.new(@c,p_outdegrees,p_edges))
    dtp.percentiles_for_sym(:katz_a_b, ReciprocityHeuristics::KatzNStepDirectedDecision.new(@c,p_outedges))
    dtp.percentiles_for_sym(:katz_b_a, ReciprocityHeuristics::KatzNStepDirectedDecision.new(@c,p_edges))
    dtp.percentiles_for(:katz_out,ReciprocityHeuristics::KatzNStepDecision.new(@c,p_outedges))
    dtp.percentiles_for(:prefattach_vw,ReciprocityHeuristics::PreferentialAttachmentDecision.new(@c,p_degrees,:v_to_w))
    dtp.percentiles_for(:prefattach_wv,ReciprocityHeuristics::PreferentialAttachmentDecision.new(@c,p_outdegrees,:w_to_v))
    dtp.output
  end
  
  def generate_csv_files_indegree(i)
    edges = get_edges_with_filter(i,:indegree)
    p_degrees = Processor.to_hash_float(@c.degrees) # In-degree of each edge
    p_outdegrees = Processor.to_hash_float(@c.degrees, 0, 2) # Out-degree of each edge
    #p_inoutdegrees = Processor.to_hash_float_block(@c.degrees, 0, 1, 2) { |indeg,outdeg| outdeg/indeg } # Out-degree/In-degree of each node
    p_inmsgs = Processor.to_hash_float(@c.people_msg, 0, 1) # In-message count of each edge
    p_outmsgs = Processor.to_hash_float(@c.people_msg, 0, 2) # Out-message count of each edge
    p_msgedges = Processor.to_tuple_hash_float(@c.rur_msg_edges(@c.k))
    p_edges = Processor.to_hash_array(@c.edges, 1, 0) # List of in-neighbors
    p_outedges = Processor.to_hash_array(@c.edges, 0, 1)
    #p_undirected_edges = Processor.to_hash_array(@c.edges, 0, 1, false)
    
    dtp = DecisionTreePreprocessor.new(@c, i, "indegree", edges)
    #dtp.percentiles_for(:indegree,ReciprocityHeuristics::DegreeDecision.new(@c,p_degrees,:in))
    dtp.percentiles_for(:outdegree,ReciprocityHeuristics::DegreeDecision.new(@c,p_outdegrees,:out))
    #dtp.percentiles_for(:inoutdegree,ReciprocityHeuristics::OutdegreePerIndegreeDecision.new(@c,p_degrees,p_outdegrees))
    dtp.percentiles_for(:inmessage,ReciprocityHeuristics::MessagesDecision.new(@c,p_inmsgs,p_msgedges,:in))
    dtp.percentiles_for(:outmessage,ReciprocityHeuristics::MessagesDecision.new(@c,p_outmsgs,p_msgedges,:out))
    #dtp.percentiles_for(:inmsgdeg,ReciprocityHeuristics::MessagesPerDegreeDecision.new(@c,p_inmsgs,p_degrees,p_msgedges,:in))
    dtp.percentiles_for(:outmsgdeg,ReciprocityHeuristics::MessagesPerDegreeDecision.new(@c,p_outmsgs,p_outdegrees,p_msgedges,:out))
    dtp.percentiles_for(:mutual_abs_in,ReciprocityHeuristics::MutualAbsoluteDecision.new(@c,p_edges,:in))
    dtp.percentiles_for(:mutual_abs_out,ReciprocityHeuristics::MutualAbsoluteDecision.new(@c,p_outedges,:out))
    dtp.percentiles_for(:jaccard_in,ReciprocityHeuristics::MutualJaccardDecision.new(@c,p_edges,:in))
    dtp.percentiles_for(:jaccard_out,ReciprocityHeuristics::MutualJaccardDecision.new(@c,p_edges,:out))
    dtp.percentiles_for(:adamic,ReciprocityHeuristics::MutualInAdamicDecision.new(@c,p_outdegrees,p_edges))
    dtp.percentiles_for_sym(:katz_a_b, ReciprocityHeuristics::KatzNStepDirectedDecision.new(@c,p_outedges))
    dtp.percentiles_for_sym(:katz_b_a, ReciprocityHeuristics::KatzNStepDirectedDecision.new(@c,p_edges))
    dtp.percentiles_for(:katz_out,ReciprocityHeuristics::KatzNStepDecision.new(@c,p_outedges))
    dtp.percentiles_for(:prefattach_vw,ReciprocityHeuristics::PreferentialAttachmentDecision.new(@c,p_degrees,:v_to_w))
    dtp.percentiles_for(:prefattach_wv,ReciprocityHeuristics::PreferentialAttachmentDecision.new(@c,p_outdegrees,:w_to_v))
    dtp.output
  end
  
  
  
  def generate_csv_files_from_parts(i, finalprefix, prefixes)
    prefix = prefixes.shift
    csv_training = "csv_training_" + prefix
    csv_test = "csv_test_" + prefix
    # Training data
    data = CSV.read(Constant.new(@c,csv_training).filename(i))
    all_top_row = data.shift
    all_data = []
    data.each do |d|
      all_data << d
    end
    # Test data
    data = CSV.read(Constant.new(@c,csv_test).filename(i))
    data.shift
    all_data_test = []
    data.each do |d|
      all_data_test << d
    end
    
    prefixes.each do |prefix|
      csv_training = "csv_training_" + prefix
      csv_test = "csv_test_" + prefix
      # Training data
      data = CSV.read(Constant.new(@c,csv_training).filename(i))
      top_row = data.shift
      all_top_row = all_top_row[0..-2] + top_row
      data.each_with_index do |d,i|
        raise RuntimeError, "Entries don't match!" unless all_data[i][-1] == d[-1]
        all_data[i] = all_data[i][0..-2] + d
      end
      # Test data
      data = CSV.read(Constant.new(@c,csv_test).filename(i))
      data.shift
      data.each_with_index do |d,i|
        raise RuntimeError, "Entries don't match!" unless all_data_test[i][-1] == d[-1]
        all_data_test[i] = all_data_test[i][0..-2] + d
      end

    end
    
    # Write out combination
    csv_training = "csv_training_" + finalprefix
    csv_test = "csv_test_" + finalprefix
    CSV.open(Constant.new(@c,csv_training).filename(i)+"~", "w") do |csv|
      csv << all_top_row
      all_data.each do |d|
        csv << d
      end
    end
    CSV.open(Constant.new(@c,csv_test).filename(i)+"~", "w") do |csv|
      csv << all_top_row
      all_data_test.each do |d|
        csv << d
      end
    end
    File.rename(Constant.new(@c,csv_training).filename(i)+"~",Constant.new(@c,csv_training).filename(i))
    File.rename(Constant.new(@c,csv_test).filename(i)+"~",Constant.new(@c,csv_test).filename(i))
  end
  
  # Generate decision tree rules using training data and test against test data
  def decision_tree_generate(i, prefix)
    csv_training = "csv_training_" + prefix
    csv_test = "csv_test_" + prefix
    decision_rules = "decision_rules_" + prefix
    decision_results = "decision_results_" + prefix
    
    #Generate
    puts "Generating rules based on training data..."
    @dt = DecisionTree.new(Constant.new(@c,csv_training).filename(i))
    File.open(Constant.new(@c,decision_rules).filename(i),"w") do |f|
      f.puts @dt.get_rules
    end
    
    # Test
    puts "Testing data on generated rules..."
    data = CSV.read(Constant.new(@c,csv_test).filename(i))
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
    File.open(Constant.new(@c,decision_results).filename(i),"w") do |f|
      f.puts "Accuracy: %d %d %.4f" % [correct, count, (correct-0.0)/count]
      f.puts "Unmatched: "
      unmatched.each { |u| f.puts u.inspect }
    end
  end
  
  # TODO Fix This
  # Generate decision tree rules using training data and test against test data
  def decision_tree_generate_rev(i, prefix)
    csv_training = "csv_training_" + prefix
    csv_test = "csv_test_" + prefix
    decision_rules = "decision_rules_rev_" + prefix
    decision_results = "decision_results_rev_" + prefix
    
    #Generate
    puts "Reverse Generating rules based on training data..."
    @dt = DecisionTree.new(Constant.new(@c,csv_test).filename(i))
    File.open(Constant.new(@c,decision_rules).filename(i),"w") do |f|
      f.puts @dt.get_rules
    end
    
    # Test
    puts "Reverse Testing data on generated rules..."
    data = CSV.read(Constant.new(@c,csv_training).filename(i))
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
    File.open(Constant.new(@c,decision_results).filename(i),"w") do |f|
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