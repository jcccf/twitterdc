require_relative 'twitterdc'
require_relative '../forestlib/processor'
include TwitterDc
include ForestLib

module TwitterDc
  module ReciprocityHeuristics
    
    module KatzNStepHelpers
      # Recursive function that computes the weighted number of simple paths of 
      # value 2 to n from a specified node to a target
      def path_rec(depth, prev_array, current, target)
        return 0 if prev_array.include? current # ignore cycles
        if depth == @n # don't continue to a depth greater than n
          #(current == target) ? (puts prev_array.inspect+current.to_s;@beta ** depth) : 0
          (current == target) ? @beta ** depth : 0
        else # depth < @n
          if current == target
            if depth == 1
              0
            else
              #(puts prev_array.inspect+current.to_s;@beta ** depth)
              @beta ** depth
            end
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
      
      def path_rec_1(depth, prev_array, current, target)
        return 0 if prev_array.include? current # ignore cycles
        if depth == @n # don't continue to a depth greater than n
          #(current == target) ? (puts prev_array.inspect+current.to_s;@beta ** depth) : 0
          (current == target) ? @beta ** depth : 0
        else # depth < @n
          if current == target
            @beta ** depth
          else
            count = 0
            neighbors = @all_edges[current]
            if neighbors
              neighbors.each do |neighbor|
                count += path_rec_1(depth+1, prev_array + [current], neighbor, target)
              end
            end
            count
          end
        end
      end
      
      def hlp(e1,e2,type)
        r = (path_rec(0, [], e1,e2) + 0.0) / path_rec(0, [], e2,e1)
        r.nan? ? 0.0 : (r > 1 ? 1.0/r : r)
      end
      
      def hlp_directed(e1,e2,type)
        r = (path_rec_1(0, [], e1,e2) + 0.0) / path_rec(0, [], e2,e1)
        r.nan? ? 0.0 : (r > 1 ? 1.0/r : r)
      end
      
      def hlp_directed_onesided(e1,e2,type)
        path_rec(0, [], e2,e1)
      end
      
      def paths_oneway(e1,e2,type)
        path_rec(0, [], e1, e2)
      end
      
    end
    

    class KatzNStepDecision
      include KatzNStepHelpers
      include BaseDecisionHelpers
  
      def initialize(c,all_edges,n=2,beta=0.05)
        @c = c
        @all_edges = all_edges
        @n = n
        @beta = beta
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
        raise ArgumentError, "KatzNStep does not do default output"
        base_output do |e1,e2,type|
          paths = @cache[e1][e2]
          paths ||= (@cache[e1][e2] = path_rec(0, [], e1, e2))
          #puts "Testing %d %d for %f >= %f" % [e1,e2,paths,@e]
          if paths >= @e
            @rec_no += 1
            @rec_correct += 1 if type == :unr
          else
            @unr_no += 1
            @unr_correct += 1 if type == :rec
          end
        end
      end
  
    end
    
    
    class KatzNStepDirectedDecision
      include KatzNStepHelpers
  
      def initialize(c,all_edges,n=2,beta=0.05)
        @c = c
        @all_edges = all_edges
        @n = n
        @beta = beta
      end
  
      def result(e1,e2,type)
        paths_oneway(e1,e2,type)
      end
      
      def result_directed(e1,e2,type)
        raise ArgumentError, "KatzNStepDirectedDecisions does not do directed percentiles"
      end
      
      def result_directed_onesided(e1,e2,type)
        raise ArgumentError, "KatzNStepDirectedDecisions does not do directed onesided percentiles"
      end
    end
    
    class KatzNStepDirected < Base
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
        @constants = Constant.new(@c, "katzdir", [edge_type, n, beta])
      end
  
      def self.constants(c, edge_type=:in, n=2, beta=0.05)
        Constant.new(c, "katzdir", [edge_type,n,beta])
      end
  
      def output_percentiles
        clear_cache
        base_output_percentiles_100 do |e1,e2,type|
          r = @cache[e1][e2]
          if not r
            r = @cache[e1][e2]
            r ||= (@cache[e1][e2] = paths_oneway(e1,e2,type))
          end
          r
        end
      end
  
      def output_directed_percentiles
        raise ArgumentError, "KatzNStepDirected does not do directed percentiles"
      end
      
      def output_directed_onesided_percentiles
        raise ArgumentError, "KatzNStepDirected does not do directed onesided percentiles"
      end
  
      def output
        raise ArgumentError, "KatzNStepDirected does not do default output"
      end
  
    end

  end
end