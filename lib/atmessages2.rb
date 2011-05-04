require 'set'
require 'stringio'
require_relative 'forestlib/forestlib'
require_relative 'twitterdc/twitterdc'
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
  
  # Predict reciprocity
  # Output in the form "a b c d e f" lines
  # a is the threshold value, b is the number of predictions of reciprocated edges
  # c is the number of correct predictions of reciprocated edges, e & f are the same
  # for unreciprocated edges, f is the total number of edges
  def build_rur_prediction(parameter=:degree, type=:absolute)
    d = case parameter
    when :degree then ReciprocityHeuristics::Indegree.new(@c)
    when :inmsg then ReciprocityHeuristics::Inmessages.new(@c)
    when :outmsg then ReciprocityHeuristics::Outmessages.new(@c)
    when :msgdeg then ReciprocityHeuristics::MessagesPerDegree.new(@c)
    when :inoutdeg then ReciprocityHeuristics::OutdegreePerIndegree.new(@c)
    when :mutualin_nbrs then ReciprocityHeuristics::MutualInJaccard.new(@c)
    when :mutualin_abs then ReciprocityHeuristics::MutualInAbsolute.new(@c)
    when :mutualin_wnbrs then ReciprocityHeuristics::MutualInAdamic.new(@c)
    when :katz then ReciprocityHeuristics::KatzNStep.new(@c)
    when :katzout then ReciprocityHeuristics::KatzNStep.new(@c,:out)
    when :katzinout then ReciprocityHeuristics::KatzNStep.new(@c,:inout)
    when :katz0005 then ReciprocityHeuristics::KatzNStep.new(@c,:in,2,0.005)
    when :katz01 then ReciprocityHeuristics::KatzNStep.new(@c,:in,2,0.1)
    when :pagerank then ReciprocityHeuristics::RootedPagerank.new(@c)
    when :pagerankout then ReciprocityHeuristics::RootedPagerank.new(@c,:out)
    when :prefattach then ReciprocityHeuristics::PreferentialAttachment.new(@c)
    else raise ArgumentError, "Invalid parameter argument supplied to build_rur_preds"
    end
    
    case type
    when :absolute then d.output
    when :percentiles then d.output_percentiles
    when :directed_percentiles then d.output_directed_percentiles
    else raise ArgumentError, "Invalid type argument supplied to build_rur_preds"
    end
  end
  
  def build_rur_prediction_plot(parameter=:degree, type=:absolute)
    constants = case parameter
    when :degree then ReciprocityHeuristics::Indegree.constants(@c)
    when :inmsg then ReciprocityHeuristics::Inmessages.constants(@c)
    when :outmsg then ReciprocityHeuristics::Outmessages.constants(@c)
    when :msgdeg then ReciprocityHeuristics::MessagesPerDegree.constants(@c)
    when :inoutdeg then ReciprocityHeuristics::OutdegreePerIndegree.constants(@c)
    when :mutualin_nbrs then ReciprocityHeuristics::MutualInJaccard.constants(@c)
    when :mutualin_abs then ReciprocityHeuristics::MutualInAbsolute.constants(@c)
    when :mutualin_wnbrs then ReciprocityHeuristics::MutualInAdamic.constants(@c)
    when :katz then ReciprocityHeuristics::KatzNStep.constants(@c)
    when :katzout then ReciprocityHeuristics::KatzNStep.constants(@c,:out)
    when :katzinout then ReciprocityHeuristics::KatzNStep.constants(@c,:inout)
    when :katz0005 then ReciprocityHeuristics::KatzNStep.constants(@c,:in,2,0.005)
    when :katz01 then ReciprocityHeuristics::KatzNStep.constants(@c,:in,2,0.1)
    when :pagerank then ReciprocityHeuristics::RootedPagerank.constants(@c)
    when :pagerankout then ReciprocityHeuristics::RootedPagerank.constants(@c,:out)
    when :prefattach then ReciprocityHeuristics::PreferentialAttachment.constants(@c)
    else raise ArgumentError, "Invalid parameter supplied to build_rur_prediction_plot"
    end
    
    eblock = Proc.new do |i,filename|
      x1, x2, x3, y1, y2, y3, y4, y5 = [], [], [], [], [], [], [], []
      File.open(filename, "r").each do |l|
        p = l.split.map!{|v| v.to_f}
        if p[1] > 0
          x1 << p[0]/100.0
          y1 << p[2]/p[1]
        end
        if p[5] > 0
          x2 << p[0]/100.0
          y2 << p[1]/p[5]
          y4 << p[3]/p[5]
          y5 << (p[2]+p[4])/p[5]
        end
        if p[3] > 0
          y3 << p[4]/p[3]
          x3 << p[0]/100.0
        end

      end
      
      #titles = ["Correctly Guessed Reciprocated/Guessed Reciprocated", "Guessed Reciprocated/Total", "Correctly Guessed Unreciprocated/Guessed Unreciprocated","Guessed Unreciprocated/Total", "Correct Guesses/Total"]
      titles = ["(E_k^r & F_theta) / F_t", "F_t/Total", "(E_k^u & F_t`) / F_t`", "F_t` / Total", "(E_k^r & F_t + E_k^u & F_t`) / Total"]
      xpN = [x1, x2, x3, x2, x2]
      ypN = [y1, y2, y3, y4, y5]
      max_accuracy_y, max_index = y5.each_with_index.max
      max_accuracy_x = x2[max_index]
      
      imagefile = case type
        when :absolute then constants.image_filename(i)
        when :percentiles then constants.pimage_filename(i)
        when :directed_percentiles then constants.dir_pimage_filename(i)
        else raise ArgumentError, "Invalid imagefile parameter"
        end
      
      Plotter.plotN("Accuracy of Prediction (Max at %.3f,%f)" % [max_accuracy_x,max_accuracy_y],"Threshold (theta)","Accuracy",titles,xpN,ypN,imagefile)
    end
    
    case type
    when :absolute then constants.filename_block &eblock
    when :percentiles then constants.pfilename_block &eblock
    when :directed_percentiles then constants.dir_pfilename_block &eblock
    else raise ArgumentError, "Invalid type argument supplied"
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