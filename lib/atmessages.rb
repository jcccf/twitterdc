require 'set'
require 'stringio'
require 'yaml'
require_relative 'adj_graph'

class AtMessages
  
  attr_accessor :people
  
  def initialize(source_filename,base_dir,n,k,k2)
    raise ArgumentException, "k <= k2 must be true" unless k <= k2
    @n = n # Look at people with >= n messages sent
    @k = k # Threshold value is k
    @k2 = k2 # Upper value of k to filter
    @source_filename = source_filename
    @base_dir = base_dir
    @people_base = base_dir+"/atmsg_people.txt"
    @people_filename = base_dir+"/atmsg_people_"+sprintf("%03d",@n)+".txt"
    @graph_filename = base_dir+"/atmsg_graph_"+sprintf("%03d",@n)+".txt"
    
    @rec_filename = base_dir+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",@k)+"_rec.txt"
    @unr_filename = base_dir+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",@k)+"_unr.txt"
    @unr_scc_filename = base_dir+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",@k)+"_unr_scc.txt"
    
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
      puts "Now filtering by #{i}"
    
      # # Now find all with more than k
      # @people.keep_if do |k,v|
      #   v.keep_if{ |k2,v2| v2 >= i }.size > 0
      # end
      
      @rec_filename = @base_dir+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_rec.txt"
      @unr_filename = @base_dir+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_unr.txt"
      @unr_scc_filename = @base_dir+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_unr_scc.txt"
      
      puts "Now building for #{i}"
      
      to_file(i)
    end
  end
  
  def find_scc
    # Check that the required files for computation exist
    @k.upto(@k2) do |i|
      raise RuntimeError, "Run build_graph before find_scc" unless File.exist? @base_dir+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_unr.txt"
    end
    
    @k.upto(@k2) do |i|
      @unr_filename = @base_dir+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_unr.txt"
      @unr_scc_filename = @base_dir+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_unr_scc.txt"
      
      puts "Now reading in graph for #{i}"
      a = AdjGraph.new
      File.open(@unr_filename,"r") do |f|
        while ln = f.gets
          parts = ln.split
          a.add_directed_edge(parts[0].to_i,parts[1].to_i)
        end
      end
      
      puts "Now calculating SCC for #{i}"
      File.open(@unr_scc_filename+"~","w") do |f|
        f.puts a.tarjan_string_limit(1000)
      end
    
      File.rename(@unr_scc_filename+"~", @unr_scc_filename)
    end
  end
  
  def degree_agreement_with_generated_graphs(min,max,step)
    raise ArgumentError, "0.0 < e < 1.0" if (min > 100 || min < 0 || max > 100 || max < 0 || max-min < 0)
    
    puts "Loading Degrees..."
    degrees = {}
    File.open(@people_filename,"r").each do |l|
      id,count = l.split
      id = id.to_i
      count = count.to_f
      degrees[id] = count
    end
    
    i = min
    begin
      puts "Agreement testing for #{i}"
      
      e = i/100.0
      e_inv = 1/e
      
      @rec_unr_agree_filename = @base_dir+"/atmsg_graph_"+sprintf("%03d",@n)+"_agreement_p#{i}.txt"
    
      File.open(@rec_unr_agree_filename+"~","w") do |f|
        @k.upto(@k2) do |i|
          match, unmatch, match2, unmatch2 = 0, 0, 0, 0
          @rec_filename = @base_dir+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_rec.txt"
          @unr_filename = @base_dir+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_unr.txt"
          
          File.open(@rec_filename,"r").each do |l|
            id1,id2 = l.split.map{ |x| x.to_i }
            ratio = degrees[id1]/degrees[id2]
            if e <= ratio && ratio <= e_inv
              match += 1
            else
              unmatch += 1
            end
          end

          File.open(@unr_filename,"r").each do |l|
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
          f.puts "%d %.4f %.4f %d %d %d %d" % [i, ratio, ratio2, match/2, unmatch/2, match2, unmatch2] # Divide by 2 since we count reciprocated matches twice
        end
      end
    
      File.rename(@rec_unr_agree_filename+"~", @rec_unr_agree_filename)
      i += step
    end while i <= max
  end
  
  private
  
  # Output the subgraphs containing only reciprocated edges and only unreciprocated edges
  def to_file(i)
    raise RuntimeError, "Call build_graph before to_file" unless @people.count > 0 #Sanity check
    
    if @people_cache.count > 0
      File.open(@rec_filename+"~","w") do |s|
        File.open(@unr_filename+"~","w") do |t|
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
      File.rename(@rec_filename+"~",@rec_filename)
      File.rename(@unr_filename+"~",@unr_filename)
    else    
      File.open(@rec_filename+"~","w") do |s|
        File.open(@unr_filename+"~","w") do |t|
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
      File.rename(@rec_filename+"~",@rec_filename)
      File.rename(@unr_filename+"~",@unr_filename)
    end
  end
  
end