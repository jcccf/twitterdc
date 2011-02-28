require 'set'
require 'stringio'
require_relative 'forestlib/adj_graph'
require_relative 'forestlib/plotter'
require_relative 'forestlib/counter'
require_relative 'forestlib/processor'
require_relative 'forestlib/disjoint_set'
require_relative 'twitterdc/constants'
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
      cnt = {}
      cntalt = {}
      File.open(out_filename,"r").each do |l|
        p = l.split.map!{|v| v.to_i}
        cnt[p[1]] ||= Hash.new(0)
        cnt[p[1]][p[2]] += 1
        cntalt[p[1]] ||= Hash.new(0)
        cntalt[p[1]][p[3]] += 1
      end
      # puts cnt.inspect
      Plotter.plotHeatMap("Reciprocated and Unreciprocated Counts Scatter Plot for k=#{i}","Reciprocated Count","Unreciprocated Count",HeatMapData.new(cnt),@c.rur_outdegrees_image(i))
      Plotter.plotHeatMap("Reciprocated and Unreciprocated Counts Alternative Scatter Plot for k=#{i}","Reciprocated Count","Unreciprocated Count",HeatMapData.new(cntalt),@c.rur_outdegrees_image_alt(i))
    end
  end
  
  # Predict reciprocity
  # Output in the form "a b c d e f" lines
  # a is the threshold value, b is the number of predictions of reciprocated edges
  # c is the number of correct predictions of reciprocated edges, e & f are the same
  # for unreciprocated edges, f is the total number of edges
  def build_rur_prediction
    @c.unreciprocated do |i,unr_filename|
      
      dupchecker = Set.new
      
      # Read in Unreciprocated Edges
      puts "Reading in Unreciprocated Edges"
      edges = []
      rec_filename = @c.reciprocated_norep(i)
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
      
      #puts edges.inspect
    
      # Read in degree counts
      degrees = Processor.to_hash_float(@c.degrees)
    
      puts "Calculating Predictions"
      File.open(@c.rur_pred_degree(i)+"~","w") do |f|
        # Step through each threshold
        ((@c.e1)..(@c.e2)).step(@c.st) do |j|
          e = j / 100.0
          e_inv = 1 / e
        
          # puts "e is #{e}"
        
          rec_no = 0
          rec_correct = 0
          unr_no = 0
          unr_correct = 0
          edges.each do |e1, e2, type|
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
        
          f.puts "#{j} #{rec_no} #{rec_correct} #{unr_no} #{unr_correct} #{edges.count}"
        end
      end
      File.rename(@c.rur_pred_degree(i)+"~",@c.rur_pred_degree(i))
    
    end
  end
  
  def build_rur_prediction_plot
    @c.rur_pred_degree do |i,filename|
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
      Plotter.plotN("Accuracy of Degree Prediction","Threshold (theta)","Accuracy",titles,xpN,ypN,@c.rur_pred_degree_image(i))
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
  
end