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
      xp, yp = [], []
      File.open(out_filename,"r").each do |l|
        p = l.split.map!{|v| v.to_f}
        xp << p[1]
        yp << p[2]
      end
      Plotter.plot("Reciprocated and Unreciprocated Counts Scatter Plot for k=#{i}","Reciprocated Count","Unreciprocated Count",xp,yp,@c.rur_outdegrees_image(i),"dots")
    end
  end
  
  # Predict reciprocity 
  def build_rur_prediction
    
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
  
end