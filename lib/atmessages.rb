require 'set'
require 'stringio'

class AtMessages
  
  # Output the set of users who have sent num or more messages.
  def self.filter_users_by_messages(filename_graph,filename_output,num)
    people = {}
    File.open(filename_graph,"r") do |file|
      while line = file.gets
        parts = line.split(' ', 2)
        people[parts[0]] ||= 0
        people[parts[0]] += 1
      end
    end
    
    File.open(filename_output+"~","w") do |ofile|
      people.each do |k,v|
        ofile.puts "#{k} #{v}" if v >= num
      end
    end
    
    File.rename(filename_output+"~",filename_output)
  end
  
  # Output the subgraph of filename consisting of edges starting with users listed in filename_users
  def self.filter_graph_by_users(filename_graph,filename_users,filename_output)
    # Read in people
    people = Set.new
    File.open(filename_users,"r") do |file|
      while line = file.gets
        parts = line.split(' ', 2)
        people.add parts[0]
      end
    end
    
    # Filter people from the original graph
    File.open(filename_output+"~","w") do |ofile|
      File.open(filename_graph) do |file|
        while line = file.gets
          parts = line.split(' ', 2)
          ofile.puts line if people.include? parts[0]
        end
      end
    end
    
    File.rename(filename_output+"~", filename_output)
  end
  
  attr_accessor :people
  
  def initialize(filename_input,k)
    @filename = filename_input
    @k = k
    @people = {}
  end
  
  # Build the graph from the file given and only keep edges where the # of messages sent is >= k
  def build_graph
    File.open(@filename, "r") do |f|
      while ln = f.gets
        parts = ln.split(" ", 3)
        p1 = parts[0].to_i
        p2 = parts[1].to_i
        @people[p1] ||= {}
        @people[p1][p2] ||= 0
        @people[p1][p2] += 1
      end
    end
    
    # Now find all with more than k
    @people.keep_if do |k,v|
      v.keep_if{ |k2,v2| v2 >= @k }.size > 0
    end
  end
  
  # Output the subgraphs containing only reciprocated edges and only unreciprocated edges
  def to_file(reciprocated_file, unreciprocated_file)
    
    raise RuntimeError, "Call build_graph before to_file" unless @people.count > 0 #Sanity check
    
    File.open(reciprocated_file+"~","w") do |s|
      File.open(unreciprocated_file+"~","w") do |t|
        @people.each do |k,v|
          v.each do |k2,v2|
            if (@people.include? k2) && (@people[k2].include? k)
              s.puts "#{k} #{k2}"
            else
              t.puts "#{k} #{k2}"
            end
          end
        end
      end
    end
    File.rename(reciprocated_file+"~",reciprocated_file)
    File.rename(unreciprocated_file+"~",unreciprocated_file)
  end
  
end