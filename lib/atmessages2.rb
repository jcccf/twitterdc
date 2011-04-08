require 'set'
require 'stringio'
require_relative 'forestlib/adj_graph'
require_relative 'forestlib/plotter'
require_relative 'forestlib/counter'
require_relative 'forestlib/processor'
require_relative 'forestlib/disjoint_set'
require_relative 'twitterdc/constants'
require_relative 'twitterdc/reciprocity_heuristics'
include ForestLib
include TwitterDc

class AtMessages2
  
  def initialize(source_filename,base_dir,n,k1,k2,e1,e2,st)
    @c = Constants.new base_dir, n, k1, k2, e1, e2, st
  end
  
  # Calculate the weakly connected component of the unreciprocated subgraphs
  def build_unrec_connected_components
    @c.unreciprocated do |i,unr_filename|
      puts "build_unrec_connected_components for #{i}"
      ds = DisjointSet.new
      File.open(unr_filename,"r").each do |l|
        id1, id2 = l.split.map!{|v| v.to_i }
        ds.add id1
        ds.add id2
        ds.union id1, id2
      end
      ds.optimize
      File.open(@c.cc_of_unreciprocated(i),"w") do |f|
        f.puts ds.largestsize
      end
    end
  end
  
  # Plot the strongly connected and weakly connected component ratios together on a chart
  def plot_scc_wcc_graphs
    Dir.mkdir @c.images_dir unless File.directory? @c.images_dir
    
    ybase = Processor.to_hash(@c.unreciprocated_node_count)
    
    xp, yp, yp2 = [],[],[]
    @c.scc_of_unreciprocated do |i,f|
      f2 = @c.cc_of_unreciprocated(i)
      xp << i.to_f
      yp << File.read(f).split(" ",2)[0].to_f / ybase[i].to_f
      yp2 << File.read(f2).split(" ",2)[0].to_f / ybase[i].to_f
    end
    
    titles = ["Largest Strongly Connected Component", "Largest Connected Component"]
    xpN = [xp, xp]
    ypN = [yp, yp2]
    
    Plotter.plotN("SCC for Unreciprocated","Threshold","Size of Largest SCC",titles,xpN,ypN,@c.scc_of_unreciprocated_image)
  end
  
  # Calculate the reciprocated/unreciprocated outdegrees for each person
  # unreciprocated is counted either by senders or receivers
  # 1st number is number of edges which are reciprocated (send >=k, recv >=k)
  # 2nd number is number of edges in which you don't get reciprocated (send >=k, recv 0)
  # 3rd number is number of edges in which you don't reciprocate (recv >=k, send 0)
  def build_rur_outdegrees
    @c.reciprocated_norep do |i,rec_norep_filename|
      unr_filename = @c.unreciprocated(i)
      out_filename = @c.rur_outdegrees(i)
      
      puts "build_rur_outdegrees building reciprocated counts for #{i}"
      # Build reciprocated counts
      rec_count = Hash.new(0)
      File.open(rec_norep_filename,"r").each do |l|
        id1, id2 = l.split.map!{|v| v.to_i}
        rec_count[id1] += 1
        rec_count[id2] += 1
      end

      puts "build_rur_outdegrees building unreciprocated counts for #{i}"
      # Build unreciprocated counts
      unr_count = Hash.new(0)
      unr_recv_count = Hash.new(0) # Count the end node
      File.open(unr_filename,"r").each do |l|
        id1, id2 = l.split.map!{|v| v.to_i}
        unr_count[id1] += 1
        unr_recv_count[id2] += 1
      end
      
      puts "build_rur_outdegrees writing out pairs for #{i}"
      # Run through people
      File.open(out_filename+"~","w") do |f|
        File.open(@c.people,"r").each do |l|
          p = l.split[0].to_i
          f.puts "#{p} #{rec_count[p]} #{unr_count[p]} #{unr_recv_count[p]}"
        end
      end
      File.rename(out_filename+"~",out_filename)
    end
  end
  
  # Plot the reciprocated/unreciprocated outdegrees for each person as a scatter plot
  def build_rur_outdegrees_plot
    @c.rur_outdegrees do |i,out_filename|
      cnt, cntalt, cntratio, cnt3d = {}, {}, {}, {}
      File.open(out_filename,"r").each do |l|
        p = l.split.map!{|v| v.to_f}
        cnt3d[p[3]] ||= {}
        cnt3d[p[3]][p[2]] ||= Hash.new(0)
        cnt3d[p[3]][p[2]][p[1]] += 1
        cnt[p[1]] ||= Hash.new(0)
        cnt[p[1]][p[2]] += 1
        cntalt[p[1]] ||= Hash.new(0)
        cntalt[p[1]][p[3]] += 1
        rec_ratio = (p[1]/(p[1]+p[2])).round(4)
        cntratio[rec_ratio] ||= Hash.new(0)
        cntratio[rec_ratio][1-rec_ratio] += 1
      end
      # puts cnt.inspect
      Plotter.plotHeatMap("Reciprocated and Unreciprocated Counts Scatter Plot for k=#{i}","Reciprocated Count","Unreciprocated Count",HeatMapData.new(cnt),@c.rur_outdegrees_image(i))
      Plotter.plotHeatMap("Reciprocated and Unreciprocated Counts Alternative Scatter Plot for k=#{i}","Reciprocated Count","Unreciprocated Count",HeatMapData.new(cntalt),@c.rur_outdegrees_image_alt(i))
      Plotter.plotHeatMap("Reciprocated and Unreciprocated Proportion Scatter Plot for k=#{i}","Reciprocated Count Proportion","Unreciprocated Count Proportion",HeatMapData.new(cntratio),@c.rur_outdegrees_image_ratio(i), '[0:1]', '[0:1]')
      Plotter.plotHeatMap3D("Reciprocated and Unreciprocated Counts 3D Scatter Plot for k=#{i}","Unreciprocated Count (Someone sent but you didn't reply)","Unreciprocated Count (You sent but there was no reply)",HeatMapData3D.new(cnt3d),@c.rur_outdegrees_image_3d(i))
    end
  end
  
  def build_rur_preds(parameter=:degree)
    @c.unreciprocated do |i,unr_filename|
      edges = read_rur_edges(unr_filename, @c.reciprocated_norep(i))
      d = case parameter
      when :degree then ReciprocityHeuristics::Indegree.new(i,@c,edges)
      when :inmsg then ReciprocityHeuristics::Inmessages.new(i,@c,edges)
      when :outmsg then ReciprocityHeuristics::Outmessages.new(i,@c,edges)
      when :msgdeg then ReciprocityHeuristics::MessagesPerDegree.new(i,@c,edges)
      when :inoutdeg then ReciprocityHeuristics::OutdegreePerIndegree.new(i,@c,edges)
      else raise ArgumentError, "Invalid parameter supplied to build_rur_preds"
      end
      d.output
    end
  end
  
  # Predict reciprocity
  # Output in the form "a b c d e f" lines
  # a is the threshold value, b is the number of predictions of reciprocated edges
  # c is the number of correct predictions of reciprocated edges, e & f are the same
  # for unreciprocated edges, f is the total number of edges
  def build_rur_prediction(parameter=:degree)
    @c.unreciprocated do |i,unr_filename|
      
      # Read in edges
      edges = read_rur_edges(unr_filename, @c.reciprocated_norep(i))
      #puts edges.inspect
    
      # Read in degree counts
      degrees = case parameter
      when :degree then Processor.to_hash_float(@c.degrees)
      when :inmsg then Processor.to_hash_float(@c.people_msg, 0, 1)
      when :outmsg then Processor.to_hash_float(@c.people_msg, 0, 2)
      when :msgdeg then
        msgs = Processor.to_hash_float(@c.people_msg, 0, 1)
        degs = Processor.to_hash_float(@c.degrees)
        degs.merge(msgs){ |k,deg,msg| msg/deg }
      when :inoutdeg then
        Processor.to_hash_float_block(@c.degrees, 0, 1, 2) { |indeg,outdeg| outdeg/indeg }
      when :mutual then
        Processor.to_hash_float(@c.degrees, 0, 2) # Get outdegrees
      when :mutualin, :mutualin_nbrs, :mutualin_abs, :mutualin_wnbrs then
        Processor.to_hash_float(@c.degrees) # Get indegrees
      else raise ArgumentException "Unknown Parameter"
      end
      
      # Read in second parameter if required
      para2 = case parameter
      when :mutual then
        Processor.to_hash_array(@c.edges)
      when :mutualin, :mutualin_nbrs, :mutualin_abs, :mutualin_wnbrs then
        Processor.to_hash_array(@c.edges, 1, 0) # Reverse
      end
        
      outfile = case parameter
        when :degree then @c.rur_pred_degree(i)
        when :inmsg then @c.rur_pred_inmsg(i)
        when :outmsg then @c.rur_pred_outmsg(i)
        when :msgdeg then @c.rur_pred_msgdeg(i)
        when :inoutdeg then @c.rur_pred_inoutdeg(i)
        when :mutual then @c.rur_pred_mutual(i)
        when :mutualin then @c.rur_pred_mutualin(i)
        when :mutualin_nbrs then @c.rur_pred_mutualin_nbrs(i)
        when :mutualin_abs then @c.rur_pred_mutualin_abs(i)
        when :mutualin_wnbrs then @c.rur_pred_mutualin_wnbrs(i)
        else raise ArgumentException "Unknown Parameter"
        end
                
      rec_no, rec_correct, unr_no, unr_correct, e, e_inv = 0, 0, 0, 0, 0.0, 0.0
      
      ehash = Hash.new({})
      
      # Choose what kind of prediction heuristic to use
      edge_block = case parameter
      when :degree, :inmsg, :outmsg, :msgdeg, :inoutdeg
        Proc.new do |e1,e2,type|
          ratio = (degrees[e1] && degrees[e2]) ? degrees[e1]/degrees[e2] : 0
          # For each edge, predict reciprocity, recino += 1
          # If the edge was reciprocated, correct += 1
          if e <= ratio && ratio <= e_inv
            rec_no += 1
            rec_correct += 1 if type == 2
          else
            unr_no += 1
            unr_correct += 1 if type == 1
          end
        end
      when :mutual, :mutualin
        Proc.new do |e1,e2,type|
          num_mutual = (para2[e1] && para2[e2]) ? 2*(para2[e1] & para2[e2]).size : 0
          total_deg = [degrees[e1] + degrees[e2] - 2.0, 0.0].max
          if total_deg == 0 || num_mutual / total_deg >= e
            rec_no += 1
            rec_correct += 1 if type == 2
          else
            unr_no += 1
            unr_correct += 1 if type == 1
          end
        end
      when :mutualin_nbrs
        Proc.new do |e1,e2,type|
          num_mutual = (para2[e1] && para2[e2]) ? (para2[e1] & para2[e2]).size : 0
          total_nbrs = ((para2[e1] ? para2[e1] : []) | (para2[e2] ? para2[e2] : [])).size
          if total_nbrs == 0 || (num_mutual / (total_nbrs-0.0)) >= e
            rec_no += 1
            rec_correct += 1 if type == 2
          else
            unr_no += 1
            unr_correct += 1 if type == 1
          end
        end
      when :mutualin_abs
        Proc.new do |e1,e2,type|
          num_mutual = (para2[e1] && para2[e2]) ? (para2[e1] & para2[e2]).size : 0
          if num_mutual >= e * 100
            rec_no += 1
            rec_correct += 1 if type == 2
          else
            unr_no += 1
            unr_correct += 1 if type == 1
          end
        end
      when :mutualin_wnbrs
        Proc.new do |e1,e2,type|
          #puts "Testing %d against %d" % [e1,e2]
          mutual = (para2[e1] ? para2[e1] : []) & (para2[e2] ? para2[e2] : [])
          # Use cached values if they exist
          score = if ehash[e1][e2]
            ehash[e1][e2]
          else
            s = 0.0
            mutual.each { |m| s += 1.0 / Math.log(degrees[m]) if degrees[m] }
            ehash[e1][e2] = s
          end
          if score >= e * 100
            rec_no += 1
            rec_correct += 1 if type == 2
          else
            unr_no += 1
            unr_correct += 1 if type == 1
          end
        end
      end
        
      puts "Calculating Predictions"
      File.open(outfile+"~","w") do |f|
        # Step through each threshold
        @c.range_array.each do |j|
          e = j / 100.0
          e_inv = 1 / e
          rec_no, rec_correct, unr_no, unr_correct = 0, 0, 0, 0
          edges.each &edge_block
          f.puts "#{j} #{rec_no} #{rec_correct} #{unr_no} #{unr_correct} #{edges.count}"
        end
      end
      File.rename(outfile+"~",outfile)
    
    end
  end
  
  def build_rur_prediction_plot(parameter=:degree)
    things_to_do = Proc.new do |i,filename|
      x, y1, y2, y3, y4, y5 = [], [], [], [], [], []
      File.open(filename, "r").each do |l|
        p = l.split.map!{|v| v.to_f}
        x << p[0]/100.0
        y1 << p[2]/p[1]
        y2 << p[1]/p[5]
        y3 << p[4]/p[3]
        y4 << p[3]/p[5]
        y5 << (p[2]+p[4])/p[5]
      end
      
      #titles = ["Correctly Guessed Reciprocated/Guessed Reciprocated", "Guessed Reciprocated/Total", "Correctly Guessed Unreciprocated/Guessed Unreciprocated","Guessed Unreciprocated/Total", "Correct Guesses/Total"]
      titles = ["(E_k^r & F_theta) / F_t", "F_t/Total", "(E_k^u & F_t`) / F_t`", "F_t` / Total", "(E_k^r & F_t + E_k^u & F_t`) / Total"]
      xpN = [x, x, x, x, x]
      ypN = [y1, y2, y3, y4, y5]
      
      imagefile = case parameter
        when :degree then @c.rur_pred_degree_image(i)
        when :inmsg then @c.rur_pred_inmsg_image(i)
        when :outmsg then @c.rur_pred_outmsg_image(i)
        when :msgdeg then @c.rur_pred_msgdeg_image(i)
        when :inoutdeg then @c.rur_pred_inoutdeg_image(i)
        when :mutual then @c.rur_pred_mutual_image(i)
        when :mutualin then @c.rur_pred_mutualin_image(i)
        when :mutualin_nbrs then @c.rur_pred_mutualin_nbrs_image(i)
        when :mutualin_abs then @c.rur_pred_mutualin_abs_image(i)
        when :mutualin_wnbrs then @c.rur_pred_mutualin_wnbrs_image(i)
        else raise ArgumentException "Unknown Parameter"
        end
      
      Plotter.plotN("Accuracy of Degree Prediction","Threshold (theta)","Accuracy",titles,xpN,ypN,imagefile)
    end
    
    files = case parameter
      when :degree then @c.rur_pred_degree &things_to_do
      when :inmsg then @c.rur_pred_inmsg &things_to_do
      when :outmsg then @c.rur_pred_outmsg &things_to_do
      when :msgdeg then @c.rur_pred_msgdeg &things_to_do
      when :inoutdeg then @c.rur_pred_inoutdeg &things_to_do
      when :mutual then @c.rur_pred_mutual &things_to_do
      when :mutualin then @c.rur_pred_mutualin &things_to_do
      when :mutualin_nbrs then @c.rur_pred_mutualin_nbrs &things_to_do
      when :mutualin_abs then @c.rur_pred_mutualin_abs &things_to_do
      when :mutualin_wnbrs then @c.rur_pred_mutualin_wnbrs &things_to_do
      else raise ArgumentException "Unknown Parameter"
      end
  end
  
  # Rebuild correct graphs for reciprocated subgraphs
  # In other words, remove replicates
  def rebuild_rec_graph
    @c.reciprocated do |i,rec_filename|
      rec_norep_filename = @c.reciprocated_norep(i)
      
      # Read in edges
      puts "rebuild_rec_graph reading in #{rec_filename}"
      edges = {}
      File.open(rec_filename,"r").each do |l|
        id1,id2 = l.split.map!{|v| v.to_i }
        id1,id2 = id2,id1 if id2 > id1
        edges[id1] ||= Set.new
        edges[id1].add id2
      end
      
      # Write edges to file
      puts "rebuild_rec_graph writing to #{rec_norep_filename}"
      File.open(rec_norep_filename+"~", "w") do |f|
        edges.each do |id1,v|
          v.each do |id2|
            f.puts "#{id1} #{id2}"
          end
        end
      end
      File.rename(rec_norep_filename+"~",rec_norep_filename)
    end
  end
  
  # Calculate number of edges in each reciprocated/unreciprocated subgraph
  # Each line is "threshold, reciprocated graph edge count, unreciprocated
  # graph edge count, ratio of rec graph count to unrec graph count"
  def build_rur_edge_count
    File.open(@c.rur_edge_count+"~", "w") do |f|    
      @c.reciprocated_norep do |i, rec_norep_filename|
        unr_filename = @c.unreciprocated(i)
        rcount, ucount = 0, 0
        File.open(rec_norep_filename, "r") do |f|
          while f.gets
          end
          rcount = ($_ == "") ? $. - 1 : $.
        end
        File.open(unr_filename, "r") do |f|
          while f.gets
          end
          ucount = ($_ == "") ? $. - 1 : $.
        end
        rcount = 0 if File.zero?(rec_norep_filename)
        ucount = 0 if File.zero?(unr_filename)
        f.puts "#{i} #{rcount} #{ucount} #{rcount.to_f/ucount.to_f}"
      end
    end
    File.rename(@c.rur_edge_count+"~",@c.rur_edge_count)
  end
  
  # Calculate the number of messages each person received in the subgraph
  def build_message_count
    
    # Read in Counts
    puts "Reading in Counts"
    counts = {}
    File.open(@c.graph, "r").each do |l|
      parts = l.split(" ", 4)
      id1, id2, cnt = parts[0].to_i, parts[1].to_i, parts[2].to_i
      counts[id1] ||= [0, 0]
      counts[id2] ||= [0, 0]
      counts[id1][1] += cnt
      counts[id2][0] += cnt
    end
    
    puts "Printing Counts"
    File.open(@c.people_msg+"~","w") do |f|
      counts.each do |k,v|
        f.puts "#{k} #{v[0]} #{v[1]}"
      end
    end
    File.rename(@c.people_msg+"~",@c.people_msg)
  end
  
  # Read in reciprocated and unreciprocated edges and create a combined edge list with
  # equal proportions of reciprocated and unreciprocated edges by choosing a random number
  # of edges from the reciprocated graph equal to the number of edges in the unreciprocated
  # graph.
  def read_rur_edges(unr_filename, rec_filename)
    
    dupchecker = Set.new
    
    # Read in Unreciprocated Edges
    puts "Reading in Unreciprocated Edges"
    edges = []
    File.open(unr_filename,"r").each do |l|
      e1, e2 = l.split.map!{|v| v.to_i }
      e1, e2 = e2, e1 if e1 > e2
      raise RuntimeError "Not supposed to exist" if dupchecker.include? [e1,e2]
      dupchecker.add [e1, e2]
      edges << [e1, e2, 1]
    end
    
    # Read in Reciprocated Edges
    puts "Reading in Reciprocated Edges"
    tmp_edges = []
    File.open(rec_filename,"r").each do |l|
      e1, e2 = l.split.map!{|v| v.to_i }
      e1, e2 = e2, e1 if e1 > e2
      raise RuntimeError "Not supposed to exist" if dupchecker.include? [e1,e2]
      dupchecker.add [e1, e2]
      tmp_edges << [e1, e2, 2]     
    end
    
    # Take N random entries from the reciprocated edge list 
    # where N = # of unreciprocated edges
    edges = edges | (tmp_edges.sort_by{rand}[0..(edges.count-1)])
    
    edges
  end
  
end