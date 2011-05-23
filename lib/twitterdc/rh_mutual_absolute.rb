require_relative 'twitterdc'
require_relative '../forestlib/processor'
include TwitterDc
include ForestLib

module TwitterDc
  module ReciprocityHeuristics
    
    module MutualAbsoluteHelpers
      def hlp(e1,e2,type)
        #puts @all_edges.inspect
        edges1 = @all_edges[e1]
        edges1 ||= []
        edges2 = @all_edges[e2]
        edges2 ||= []
        edges1 -= [e2]
        edges2 -= [e1]
        # puts "#{e1} #{e2} #{type.to_s} #{@edge_type.to_s}"
        # puts @all_edges[e1].inspect
        # puts @all_edges[e2].inspect
        # puts edges1.inspect
        # puts edges2.inspect
        (edges1 & edges2).size
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
        (edges1 & edges2).size
      end
      
      def hlp_directed_onesided(e1,e2,type)
        raise ArgumentError, "MutualAbsolute does not care about onesided"
        # edges2 = @all_edges[e2]
        # edges2 ||= []
        # if @edge_type == :out
        #   edges2 -= [e1]
        # end
        # edges2.size
      end
    end
    
    class MutualAbsoluteDecision
      include BaseDecisionHelpers
      include MutualAbsoluteHelpers
      
      def initialize(c, all_edges, edge_type)
        @edge_type = edge_type
        @all_edges = all_edges
      end
      
    end
    
    class MutualAbsolute < Base
      include BaseHelpers
      include MutualAbsoluteHelpers
      
      def initialize(c, edge_type=:in)
        super(c)
        @edge_type = edge_type
        @all_edges = case edge_type
          when :in then Processor.to_hash_array(@c.edges, 1, 0) # Reverse
          when :out then Processor.to_hash_array(@c.edges, 0, 1)
          else raise ArgumentError, "Invalid edge type specified"
          end
        @constants = Constant.new(c, "mutual_abs", [edge_type])
      end
      
      def self.constants(c, edge_type=:in)
        Constant.new(c, "mutual_abs", [edge_type])
      end
      
      def output
        base_output do |e1,e2,type|
          num_mutual = (@all_edges[e1] && @all_edges[e2]) ? (@all_edges[e1] & @all_edges[e2]).size : 0
          if num_mutual >= @e * 100
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