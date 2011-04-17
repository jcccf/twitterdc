require_relative 'constants'
require_relative 'constant'
require_relative '../forestlib/processor'
include TwitterDc
include ForestLib

module TwitterDc
  module ReciprocityHeuristics
    
    class Helpers
      
      # Read in reciprocated and unreciprocated edges and create a combined edge list with
      # equal proportions of reciprocated and unreciprocated edges by choosing a random number
      # of edges from the reciprocated graph equal to the number of edges in the unreciprocated
      # graph. If balanced is set to false then just return all edges
      def self.read_rur_edges(unr_filename, rec_filename, balanced=true)

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
        if balanced
          edges = edges | (tmp_edges.sort_by{rand}[0..(edges.count-1)])
        else
          edges = edges | tmp_edges
        end
        edges
      end
    end
    
    # Base module that all heuristics MUST include
    module BaseHelpers
      def base_output &edge_block
        @c.unreciprocated do |i,unr_filename|
          # Check if @outfile class variable is a method name (like for Indegree) 
          # or a Proc (like for Katz)
          outfile = @constants.filename(i)
          edges = Helpers.read_rur_edges(unr_filename, @c.reciprocated_norep(i))
          File.open(outfile+"~","w") do |f|
            # Step through each threshold
            @c.range_array.each do |j|
              @e = j / 100.0
              @e_inv = 1 / @e
              @rec_no, @rec_correct, @unr_no, @unr_correct = 0, 0, 0, 0
              edges.each &edge_block
              f.puts "#{j} #{@rec_no} #{@rec_correct} #{@unr_no} #{@unr_correct} #{edges.count}"
            end
          end
          File.rename(outfile+"~",outfile)
        end
      end
      
      # Prediction based on whether the variable is between e and 1/e
      def e_to_einv_proc(my_var)
        Proc.new do |e1,e2,type|
          ratio = (my_var[e1] && my_var[e2]) ? my_var[e1]/my_var[e2] : 0
          # For each edge, predict reciprocity, rec_no += 1
          # If the edge was reciprocated, correct += 1
          if @e <= ratio && ratio <= @e_inv
            @rec_no += 1
            @rec_correct += 1 if type == 2
          else
            @unr_no += 1
            @unr_correct += 1 if type == 1
          end
        end
      end
    end
    
    # Base class that all heuristics inherit from
    class Base
      def initialize(c)
        @c = c
        @cache = Hash.new({})
      end
    end
    
    class Indegree < Base
      include BaseHelpers
      
      def initialize(c)
        super
        @indegrees = Processor.to_hash_float(@c.degrees)
        @constants = Constant.new(c, "degree")
      end
      
      def self.constants(c)
        Constant.new(c, "degree")
      end
      
      def output
        base_output &e_to_einv_proc(@indegrees)
      end
    end
    
    class Inmessages < Base
      include BaseHelpers
      
      def initialize(c)
        super
        @inmessages = Processor.to_hash_float(@c.people_msg, 0, 1)
        @constants = Constant.new(c, "inmsg")
      end
      
      def self.constants(c)
        Constant.new(c, "inmsg")
      end
      
      def output
        base_output &e_to_einv_proc(@inmessages)
      end
    end
    
    class Outmessages < Base
      include BaseHelpers
      
      def initialize(c)
        super
        @outmessages = Processor.to_hash_float(@c.people_msg, 0, 2)
        @constants = Constant.new(c, "outmsg")
      end
      
      def self.constants(c)
        Constant.new(c, "outmsg")
      end
      
      def output
        base_output &e_to_einv_proc(@outmessages)
      end
    end
    
    class MessagesPerDegree < Base
      include BaseHelpers
      
      def initialize(c)
        super
        msgs = Processor.to_hash_float(@c.people_msg, 0, 1)
        degs = Processor.to_hash_float(@c.degrees)
        @msgdeg = degs.merge(msgs){ |k,deg,msg| msg/deg }
        @constants = Constant.new(c, "msgdeg")
      end
      
      def self.constants(c)
        Constant.new(c, "msgdeg")
      end
      
      def output
        base_output &e_to_einv_proc(@msgdeg)
      end
    end
    
    class OutdegreePerIndegree < Base
      include BaseHelpers
      
      def initialize(c)
        super
        @outindeg = Processor.to_hash_float_block(@c.degrees, 0, 1, 2) { |indeg,outdeg| outdeg/indeg }
        @constants = Constant.new(c, "inoutdeg")
      end
      
      def self.constants(c)
        Constant.new(c, "inoutdeg")
      end
      
      def output
        base_output &e_to_einv_proc(@outindeg)
      end
    end
    
    class MutualInJaccard < Base
      include BaseHelpers
      
      def initialize(c)
        super
        @all_edges = Processor.to_hash_array(@c.edges, 1, 0) # Reverse
        @constants = Constant.new(c, "mutualin_nbrs")
      end
      
      def self.constants(c)
        Constant.new(c, "mutualin_nbrs")
      end
      
      def output
        base_output do |e1,e2,type|
          num_mutual = (@all_edges[e1] && @all_edges[e2]) ? (@all_edges[e1] & @all_edges[e2]).size : 0
          total_nbrs = ((@all_edges[e1] ? @all_edges[e1] : []) | (@all_edges[e2] ? @all_edges[e2] : [])).size
          if total_nbrs == 0 || (num_mutual / (total_nbrs-0.0)) >= @e
            @rec_no += 1
            @rec_correct += 1 if type == 2
          else
            @unr_no += 1
            @unr_correct += 1 if type == 1
          end
        end
      end
    end
    
    class MutualInAbsolute < Base
      include BaseHelpers
      
      def initialize(c)
        super
        @all_edges = Processor.to_hash_array(@c.edges, 1, 0) # Reverse
        @constants = Constant.new(c, "mutualin_abs")
      end
      
      def self.constants(c)
        Constant.new(c, "mutualin_abs")
      end
      
      def output
        base_output do |e1,e2,type|
          num_mutual = (@all_edges[e1] && @all_edges[e2]) ? (@all_edges[e1] & @all_edges[e2]).size : 0
          if num_mutual >= @e * 100
            @rec_no += 1
            @rec_correct += 1 if type == 2
          else
            @unr_no += 1
            @unr_correct += 1 if type == 1
          end
        end
      end
    end
    
    module MutualInAdamicHelpers
      def weighted_score(e1,e2)
        mutual = (@all_edges[e1] ? @all_edges[e1] : []) & (@all_edges[e2] ? @all_edges[e2] : [])
        s = 0.0
        mutual.each { |m| s += 1.0 / Math.log(@outdegrees[m]) if @outdegrees[m] }
        s
      end
    end
    
    class MutualInAdamicDecision
      include MutualInAdamicHelpers
      
      def initialize(c,outdegrees,all_edges)
        @c = c
        @outdegrees = outdegrees
        @all_edges = all_edges
      end
      
      def result(e1,e2)
        weighted_score(e1,e2)
      end
    end
    
    class MutualInAdamic < Base
      include BaseHelpers
      include MutualInAdamicHelpers
      
      def initialize(c)
        super
        @outdegrees = Processor.to_hash_float(@c.degrees, 0, 2)
        @all_edges = Processor.to_hash_array(@c.edges, 1, 0) # Reverse
        @constants = Constant.new(c, "adamic")
      end
      
      def self.constants(c)
        Constant.new(c, "adamic")
      end
      
      def output
        base_output do |e1,e2,type|
          #puts "Testing %d against %d" % [e1,e2]
          score = @cache[e1][e2]
          score ||= (@cache[e1][e2] = weighted_score(e1,e2))
          if score >= @e * 100
            @rec_no += 1
            @rec_correct += 1 if type == 2
          else
            @unr_no += 1
            @unr_correct += 1 if type == 1
          end
        end
      end
    end
    
    module KatzNStepHelpers
      # Recursive function that computes the weighted number of simple paths of 
      # value 1 to n from a specified node to a target
      def path_rec(depth, prev_array, current, target)
        return 0 if prev_array.include? current # ignore cycles
        if depth == @n # don't continue to a depth greater than n
          (current == target) ? (puts prev_array.inspect+current.to_s;@beta ** depth) : 0
        else # depth < @n
          if current == target
            (puts prev_array.inspect+current.to_s;@beta ** depth)
          else
            count = 0
            neighbors = @all_edges[current]
            if neighbors
              neighbors.each do |neighbor|
                count += path_rec(depth+1, prev_array + [current], neighbor, target)
              end
            end
            count
          end
        end
      end
    end
    
    class KatzNStepDecision
      include KatzNStepHelpers
      
      def initialize(c,all_edges,n=2,beta=0.05)
        @c = c
        @all_edges = all_edges
        @n = n
        @beta = beta
      end
      
      def result(e1,e2)
        path_rec(0, [], e1, e2)
      end
      
    end
    
    class KatzNStep < Base
      include BaseHelpers
      include KatzNStepHelpers
      
      def initialize(c,edge_type=:in, n=2,beta=0.05)
        super(c)
        @n = n
        @beta = beta
        @edge_type = edge_type
        @all_edges = case edge_type
          when :in then Processor.to_hash_array(@c.edges, 1, 0) # Reverse (receiver => sender)
          when :out then Processor.to_hash_array(@c.edges) # Directed edges, sender => receiver
          when :inout then Processor.to_hash_array(@c.edges, 0, 1, false) # Undirected, sender <=> receiver
          else raise ArgumentException, "Invalid edge_type supplied"
          end
        @constants = Constant.new(@c, "katz", [edge_type, n, beta])
      end
      
      def self.constants(c, edge_type=:in, n=2, beta=0.05)
        Constant.new(c, "katz", [edge_type,n,beta])
      end
      
      def output
        base_output do |e1,e2,type|
          paths = @cache[e1][e2]
          paths ||= (@cache[e1][e2] = path_rec(0, [], e1, e2))
          #puts "Testing %d %d for %f >= %f" % [e1,e2,paths,@e]
          if paths >= @e
            @rec_no += 1
            @rec_correct += 1 if type == 2
          else
            @unr_no += 1
            @unr_correct += 1 if type == 1
          end
        end
      end
      
    end
    
    module RootedPagerankHelpers
      # Run rooted pagerank for n iterations with root e1
      # With probability @a, return to e1, with probability 1-@a, jump to a random node
      def run_iterations(e1,e2,n = 1000)
        puts "Running Rooted Pagerank for (#{e1},#{e2})..."
        a = @a
        ap = 1.0 - @a
        w = Hash.new(0.0)
        w[e1] = 1.0
        n.times do |i|
          (puts "%f %f" % [i, w[e2]]) if i % 50 == 0
          w_new = Hash.new(0.0)
          w.each do |k,v|
            w_new[e1] += a * v
            if @all_edges[k]
              w_new[@all_edges[k].sample] += ap * v
            else
              w_new[k] += ap * v
            end
          end
          w = w_new
        end
        #puts w.inspect
        w[e2]
      end
    end
    
    class RootedPagerankDecision
      include RootedPagerankHelpers
      
      def initialize(c,all_edges,alpha=0.15)
        @c = c
        @all_edges = all_edges
        @a = alpha
      end
      
      def result(e1,e2)
        run_iterations(e1,e2)
      end
      
    end
    
    class RootedPagerank < Base
      include BaseHelpers
      include RootedPagerankHelpers
      
      def initialize(c,edge_type=:in,alpha=0.15)
        super(c)
        @a = alpha
        @edge_type = edge_type
        @all_edges = case edge_type
          when :in then Processor.to_hash_array(@c.edges, 1, 0) # Reverse (receiver => sender)
          when :out then Processor.to_hash_array(@c.edges) # Directed edges, sender => receiver
          end
        @constants = Constant.new(c, "pagerank", [edge_type,alpha])
      end
      
      def self.constants(c, edge_type=:in, alpha=0.15)
        Constant.new(c, "pagerank", [edge_type,alpha])
      end
      
      def output
        base_output do |e1,e2,type|
          e2_stationary = @cache[e1][e2]
          e2_stationary ||= (@cache[e1][e2] = run_iterations(e1,e2))
          if e2_stationary >= @e
            @rec_no += 1
            @rec_correct += 1 if type == 2
          else
            @unr_no += 1
            @unr_correct += 1 if type == 1
          end
        end
      end
      
    end
    
  end
end

c = ReciprocityHeuristics::RootedPagerank.constants(Constants.new("abc",500,10,30))