require 'set'
require 'stringio'
require 'yaml'
require_relative 'forestlib/adj_graph'
require_relative 'forestlib/plotter'
require_relative 'forestlib/counter'
require_relative 'forestlib/processor'
require_relative 'twitterdc/constants'
include ForestLib
include TwitterDc

class AtMessages
  
  attr_accessor :people
  
  def initialize(source_filename,base_dir,n,k,k2)
    @c = Constants.new base_dir, n, k, k2
    
    raise ArgumentException, "k <= k2 must be true" unless k <= k2
    @n = n # Look at people with >= n messages sent
    @k = k # Threshold value is k
    @k2 = k2 # Upper value of k to filter
    @source_filename = source_filename
    @people_base = base_dir+"/atmsg_people.txt"
    @people_filename = base_dir+"/atmsg_people_"+sprintf("%03d",@n)+".txt"
    @people_deg_filename = base_dir+"/atmsg_people_"+sprintf("%03d",@n)+"_degree.txt"
    @people_edge_filename = base_dir+"/atmsg_people_"+sprintf("%03d",@n)+"_edges.txt"
    @graph_filename = base_dir+"/atmsg_graph_"+sprintf("%03d",@n)+".txt"
    
    @people = {}
    @people_cache = {}
  end
  
  # Output the set of users who have sent num or more messages.
  def filter_users_by_messages
    puts "Calculating total messages sent by each person"
    people = {}
    count = 0
    File.open(@source_filename,"r").each do |line|
      parts = line.split(' ', 4)
      p, c = parts[0].to_i, parts[2].to_i
      people[p] ||= 0
      people[p] += c
      count += 1
      print "." if count % 1000 == 0
    end
    
    # Write to base
    puts "Writing to base..."
    File.open(@people_base,"w") do |f|
      people.each { |k,v| f.puts "#{k} #{v}" }
    end
    
    puts "Filtering people by >= #{@n}"
    File.open(@people_filename+"~","w") do |ofile|
      people.each do |k,v|
        ofile.puts "#{k} #{v}" if v >= @n
      end
    end
    File.rename(@people_filename+"~",@people_filename)
  end
  
  # Output the subgraph of filename consisting of edges starting with users listed in filename_users
  def filter_graph_by_users
    raise RuntimeError, "Call filter_users_by_messages before filter_graph_by_users" unless File.exist? @people_filename
    
    # Read in people
    puts "Reading in people..."
    people = Set.new
    File.open(@people_filename,"r").each do |l|
      people.add(l.split(' ', 2)[0])
    end
    
    # Filter people from the original graph
    puts "Filtering graph by >= #{@n} for sender and receiver"
    File.open(@graph_filename+"~","w") do |ofile|
      File.open(@source_filename) do |file|
        while line = file.gets
          parts = line.split(' ', 3)
          ofile.puts line if (people.include? parts[0]) && (people.include? parts[1])
        end
      end
    end
    
    File.rename(@graph_filename+"~", @graph_filename)
  end
  
  # Find the degree counts and edges in the graph corresponding to n
  def find_degrees_edges
    raise RuntimeError, "Call filter_graph_by_users before find_degrees" unless File.exist? @graph_filename
    
    # Open graph file and read in undirected edges
    puts "Reading in edges from graph..."
    edges = {}
    File.open(@graph_filename,"r").each do |l|
      parts = l.split(' ',3)
      id1,id2 = parts[0].to_i, parts[1].to_i
      id1,id2 = id2,id1 if id2 < id1
      edges[id1] ||= Set.new
      edges[id1].add id2
    end
    
    # Count degrees
    puts "Counting degrees of each node and writing undirected edges..."
    degrees = {}
    File.open(@people_edge_filename+"~", "w") do |f|
      edges.each do |k,v|
        v.each do |k2|
          f.puts "#{k} #{k2}"
          degrees[k] ||= 0
          degrees[k2] ||= 0
          degrees[k] += 1
          degrees[k2] += 1
        end
      end
    end
    File.rename(@people_edge_filename+"~", @people_edge_filename)
  
    # Loop through edges and count and write to file
    puts "Writing to file..."
    File.open(@people_deg_filename+"~", "w") do |f|
      degrees.each do |k,v|
        f.puts "#{k} #{v}"
      end
    end
    File.rename(@people_deg_filename+"~", @people_deg_filename)
    
  end
  
  # Build the graph from the file given and only keep edges where the # of messages sent is >= k
  def build_graph
    raise RuntimeError, "Call filter_graph_by_users before build_graph" unless File.exist? @graph_filename
    
    c = 0
    File.open(@graph_filename,"r").each do |l|
      parts = l.split(' ',4)
      sender, receiver, count = parts[0].to_i, parts[1].to_i, parts[2].to_i
      people[sender] ||= {}
      people[sender][receiver] ||= 0
      people[sender][receiver] += count
      print "." if c % 1000 == 0
      c += 1
    end
    
    @k.upto(@k2) do |i|
      puts "Now building for #{i}"
      to_file(i)
    end
  end
  
  # Count the number of nodes in the reciprocated and unreciprocated subgraphs
  def count_nodes_rec_unr
    File.open(@c.reciprocated_node_count, "w") do |r|
      File.open(@c.unreciprocated_node_count, "w") do |u|
        @c.reciprocated do |i,rec_filename|
          unr_filename = @c.unreciprocated(i)
          r.puts "#{i} #{Counter.unique_nodes(rec_filename, 0, 1)}"
          u.puts "#{i} #{Counter.unique_nodes(unr_filename, 0, 1)}"
        end
      end
    end
  end
  
  # Find the strongly connected components in the unreciprocated subgraphs
  def find_scc
    # Check that the required files for computation exist
    @c.unreciprocated do |i,unr_filename|
      raise RuntimeError, "Run build_graph before find_scc" unless File.exist? unr_filename
    end
    
    @c.unreciprocated do |i,unr_filename|
      scc_filename = @c.scc_of_unreciprocated(i)
      
      puts "Now reading in graph for #{i}"
      a = AdjGraph.new
      File.open(unr_filename,"r") do |f|
        while ln = f.gets
          parts = ln.split
          a.add_directed_edge(parts[0].to_i,parts[1].to_i)
        end
      end
      
      puts "Now calculating SCC for #{i}"
      File.open(scc_filename+"~","w") do |f|
        f.puts a.tarjan_string_limit(1000)
      end
      File.rename(scc_filename+"~", scc_filename)
    end
  end
  
  # Build the reciprocated and unreciprocated subgraphs based on the degrees of the original
  # graph, and looking at the ratio e
  # Note! The reciprocated subgraph DOES NOT repeat edges!
  def build_prediction_on_degree(min,max,step)
    degrees = Processor.to_hash_float(@people_deg_filename)
    puts degrees.inspect
    (min..max).step(step) do |i|
      
      puts "Building for #{i}"
      
      e = i/100.0
      e_inv = 1/e
      
      File.open(@c.reciprocated_pred_deg(i)+"~","w") do |r|
        File.open(@c.unreciprocated_pred_deg(i)+"~","w") do |u|
          File.open(@people_edge_filename, "r").each do |l|
            id1,id2 = l.split.map{ |x| x.to_i }
            ratio = degrees[id1]/degrees[id2]
            puts ratio
            if e <= ratio && ratio <= e_inv
              r.puts l
            else
              u.puts l
            end
          end
        end
      end
      File.rename(@c.reciprocated_pred_deg(i)+"~",@c.reciprocated_pred_deg(i))
      File.rename(@c.unreciprocated_pred_deg(i)+"~",@c.unreciprocated_pred_deg(i))
    end
  end
  
  # Compare how a prediction based on degree or message count compares with the reciprocated and
  # unreciprocated subgraphs generated
  def degree_agreement_with_generated_graphs(min,max,step,type = :degree)
    raise ArgumentError, "0.0 < e < 1.0" if (min > 100 || min < 0 || max > 100 || max < 0 || max-min < 0)
    
    dfile = if type == :msg_count
      @people_filename
    elsif type == :degree
      @people_deg_filename
    end
    
    puts "Loading Degrees..."
    degrees = {}
    File.open(dfile,"r").each do |l|
      id,count = l.split
      id = id.to_i
      count = count.to_f
      degrees[id] = count
    end
    
    (min..max).step(step) do |i|
      puts "Agreement testing for #{i}"
      
      e = i/100.0
      e_inv = 1/e
      
      agree_filename = @c.agreement(i)
    
      File.open(agree_filename+"~","w") do |f|
        @c.reciprocated do |i, rec_filename|
          match, unmatch, match2, unmatch2 = 0, 0, 0, 0
          unr_filename = @c.unreciprocated(i)
          
          File.open(rec_filename,"r").each do |l|
            id1,id2 = l.split.map{ |x| x.to_i }
            ratio = degrees[id1]/degrees[id2]
            if e <= ratio && ratio <= e_inv
              match += 1
            else
              unmatch += 1
            end
          end

          File.open(unr_filename,"r").each do |l|
            id1,id2 = l.split.map{ |x| x.to_i }
            ratio = degrees[id1]/degrees[id2]
            if ratio < e || e_inv < ratio
              match2 += 1
            else
              unmatch2 += 1
            end
          end
          ratio = (match+unmatch > 0) ? match/(match+unmatch).to_f : 0
          ratio2 = (match2+unmatch2 > 0) ? match2/(match2+unmatch2).to_f : 0
          # Divide by 2 below since we count reciprocated matches twice
          f.puts "%d %.4f %.4f %d %d %d %d" % [i, ratio, ratio2, match/2, unmatch/2, match2, unmatch2] 
        end
      end
    
      File.rename(agree_filename+"~", agree_filename)
    end
  end
  
  # Plot the strongly connected component counts on a chart
  def plot_scc_graphs
    Dir.mkdir @c.images_dir unless File.directory? @c.images_dir
    
    ybase = Processor.to_hash(@c.unreciprocated_node_count)
    
    xp,yp = [],[]
    @c.scc_of_unreciprocated do |i,f|
      xp << i.to_f
      yp << File.read(f).split(" ",2)[0].to_f / ybase[i].to_f
    end
    Plotter.plot("SCC for Unreciprocated","Threshold","Size of Largest SCC",xp,yp,@c.scc_of_unreciprocated_image)
  end
  
  private
  
  # Output the subgraphs containing only reciprocated edges and only unreciprocated edges
  # NOTE! the graph of reciprocated edges DOES contain repeated edges!
  def to_file(i)
    raise RuntimeError, "Call build_graph before to_file" unless @people.count > 0 #Sanity check
    
    rec_filename = @c.reciprocated(i)
    unr_filename = @c.unreciprocated(i)
    
    if @people_cache.count > 0
      File.open(rec_filename+"~","w") do |s|
        File.open(unr_filename+"~","w") do |t|
          @people_cache.each do |k,v|
            v.each do |k2,v2|
              vf, vrev = v2
              if vf >= i
                if vrev >= i
                  s.puts "#{k} #{k2}"
                elsif vrev == 0
                  t.puts "#{k} #{k2}"
                end
              end
            end
          end
        end
      end
      File.rename(rec_filename+"~",rec_filename)
      File.rename(unr_filename+"~",unr_filename)
    else    
      File.open(rec_filename+"~","w") do |s|
        File.open(unr_filename+"~","w") do |t|
          @people.each do |k,v|
            v.each do |k2,v2|
              if v2 >= i
                if @people.include? k2
                  if @people[k2].include? k
                    s.puts "#{k} #{k2}" if @people[k2][k] >= i
                    @people_cache[k] ||= {}
                    @people_cache[k][k2] = [v2, @people[k2][k]]
                  else
                    t.puts "#{k} #{k2}"
                    @people_cache[k] ||= {}
                    @people_cache[k][k2] = [v2, 0]
                  end
                else
                  t.puts "#{k} #{k2}"
                  @people_cache[k] ||= {}
                  @people_cache[k][k2] = [v2, 0]
                end
              end
            end
          end
        end
      end
      File.rename(rec_filename+"~",rec_filename)
      File.rename(unr_filename+"~",unr_filename)
    end
  end
  
end