require_relative 'twitterdc'
require_relative '../forestlib/processor'
include TwitterDc
include ForestLib

module TwitterDc
  module ReciprocityHeuristics
    
    module MutualJaccardHelpers
      def hlp(e1,e2,type)
        #puts @all_edges.inspect
        edges1 = @all_edges[e1]
        edges1 ||= []
        edges2 = @all_edges[e2]
        edges2 ||= []
        edges1 -= [e2]
        edges2 -= [e1]
        n = (edges1 & edges2).size
        u = (edges1 | edges2).size
        (u == 0) ? 0 : (n-0.0)/u
      end
      
      def hlp_directed(e1,e2,type)
        edges1 = @all_edges[e1]
        edges1 ||= []
        edges2 = @all_edges[e2]
        edges2 ||= []
        if @edge_type == :out
          edges2 -= [e1]
        else
          edges1 -= [e2]
        end
        n = (edges1 & edges2).size
        u = (edges1 | edges2).size
        (u == 0) ? 0 : (n-0.0)/u
      end
      
      def hlp_directed_onesided(e1,e2,type)
        raise ArgumentError, "MutualJaccard does not care about onesided"
      end
    end
    
    class MutualJaccardDecision
      include BaseDecisionHelpers
      include MutualJaccardHelpers
      
      def initialize(c, all_edges, edge_type)
        @edge_type = edge_type
        @all_edges = all_edges
      end
      
    end
    
    class MutualJaccard < Base
      include BaseHelpers
      include MutualJaccardHelpers
      
      def initialize(c,edge_type=:in)
        super(c)
        @all_edges = case edge_type
          when :in then Processor.to_hash_array(@c.edges, 1, 0) # Reverse
          when :out then Processor.to_hash_array(@c.edges, 0, 1)
          end
        @edge_type = edge_type
        @constants = Constant.new(c, "mutualin_nbrs", [edge_type])
      end
      
      def self.constants(c, edge_type=:in)
        Constant.new(c, "mutualin_nbrs", [edge_type])
      end
      
      def output
        base_output do |e1,e2,type|
          num_mutual = (@all_edges[e1] && @all_edges[e2]) ? (@all_edges[e1] & @all_edges[e2]).size : 0
          total_nbrs = ((@all_edges[e1] ? @all_edges[e1] : []) | (@all_edges[e2] ? @all_edges[e2] : [])).size
          if total_nbrs == 0 || (num_mutual / (total_nbrs-0.0)) >= @e
            @rec_no += 1
            @rec_correct += 1 if type == :rec
          else
            @unr_no += 1
            @unr_correct += 1 if type == :unr
          end
        end
      end
    end
  end
end