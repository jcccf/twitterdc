require_relative 'twitterdc'
require_relative '../forestlib/processor'
include TwitterDc
include ForestLib

module TwitterDc
  module ReciprocityHeuristics
    
    module DegreeHelpers
      def hlp(e1,e2,type)
        d1, d2 = @degrees[e1], @degrees[e2]
        if type == :rec
          d1 -= 1
          d2 -= 1
        else
          if @edge_type == :in
            d2 -= 1
          else
            d1 -= 1
          end
        end
        r = d1 / d2
        r.nan? ? 0.0 : (r > 1 ? 1.0/r : r)
      end
      
      def hlp_directed(e1,e2,type)
        d1, d2 = @degrees[e1], @degrees[e2]
        if type == :rec
          if @edge_type == :in
            d1 -= 1
          else
            d2 -= 1
          end
        end
        r = d1 / d2
        r.nan? ? 0.0 : r
      end
      
      def hlp_directed_onesided(e1,e2,type)
        d2 = @degrees[e2]
        if type == :rec
          if @edge_type == :out
            d2 -= 1
          end
        end
        d2
      end
      
      def hlp_directed_v(e1,e2,type)
        d1 = @degrees[e1]
        if type == :rec
          if @edge_type == :in
            d1 -= 1
          end
        end
        d1
      end
    end
    
    class DegreeDecision
      include BaseDecisionHelpers
      include DegreeHelpers
      
      def initialize(c,degrees,edge_type)
        @degrees = degrees
        @edge_type = edge_type
      end
      
    end
    
    class Degree < Base
      include BaseHelpers
      include DegreeHelpers
      
      def initialize(c,edge_type=:in)
        super(c)
        @edge_type = edge_type
        @degrees = case edge_type
          when :in then Processor.to_hash_float(@c.degrees)
          when :out then Processor.to_hash_float(@c.degrees, 0, 2)
          end
        @constants = Constant.new(c, "degree", [edge_type])
      end
      
      def self.constants(c, edge_type=:in)
        Constant.new(c, "degree", [edge_type])
      end
      
      def output
        base_output &e_to_einv_proc(@indegrees)
      end
    end
    
  end
end