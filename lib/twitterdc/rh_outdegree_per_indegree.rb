require_relative 'twitterdc'
require_relative '../forestlib/processor'
include TwitterDc
include ForestLib

module TwitterDc
  module ReciprocityHeuristics
    
    module OutdegreePerIndegreeHelpers
      def hlp(e1,e2,type)
        e1_out, e2_out, e1_in, e2_in = @outdegrees[e1], @outdegrees[e2], @indegrees[e1], @indegrees[e2]
        if type == :rec
          e1_out -= 1
          e2_out -= 1
          e1_in -= 1
          e2_in -= 1
        else
          e1_out -= 1
          e2_in -= 1
        end
        #puts e1_out, e1_in, e2_out, e2_in
        e1_r = ( e1_out / e1_in )
        e2_r = ( e2_out / e2_in )
        e1_r = e1_r.nan? ? 0.0 : e1_r
        e2_r = e2_r.nan? ? 0.0 : e2_r
        r = e1_r / e2_r
        r.nan? ? 0.0 : (r > 1 ? 1.0/r : r)
      end
      
      def hlp_directed(e1,e2,type)
        e1_out, e2_out, e1_in, e2_in = @outdegrees[e1], @outdegrees[e2], @indegrees[e1], @indegrees[e2]
        if type == :rec
          e2_out -= 1
          e1_in -= 1
        end
        e1_r = ( e1_out / e1_in )
        e2_r = ( e2_out / e2_in )
        e1_r = e1_r.nan? ? 0.0 : e1_r
        e2_r = e2_r.nan? ? 0.0 : e2_r
        r = e1_r / e2_r
        r.nan? ? 0.0 : r
      end
      
      def hlp_directed_onesided(e1,e2,type)
        e2_out, e2_in = @outdegrees[e2], @indegrees[e2]
        if type == :rec
          e2_out -= 1
        end
        r = e2_out / e2_in
        r.nan? ? 0.0 : r
      end
      
      def hlp_directed_v(e1,e2,type)
        e1_out, e1_in = @outdegrees[e1], @indegrees[e1]
        if type == :rec
          e1_in -= 1
        end
        r = e1_out / e1_in
        r.nan? ? 0.0 : r
      end
    end
    
    class OutdegreePerIndegreeDecision
      include OutdegreePerIndegreeHelpers
      include BaseDecisionHelpers
      
      def initialize(c,indegrees,outdegrees)
        @indegrees = indegrees
        @outdegrees = outdegrees
      end
      
    end
    
    class OutdegreePerIndegree < Base
      include BaseHelpers
      include OutdegreePerIndegreeHelpers
      
      def initialize(c)
        super
        @outindeg = Processor.to_hash_float_block(@c.degrees, 0, 1, 2) { |indeg,outdeg| outdeg/indeg }
        @indegrees = Processor.to_hash_float(@c.degrees)
        @outdegrees = Processor.to_hash_float(@c.degrees, 0, 2)
        @constants = Constant.new(c, "inoutdeg")
      end
      
      def self.constants(c)
        Constant.new(c, "inoutdeg")
      end
      
      def output
        base_output &e_to_einv_proc(@outindeg)
      end
    end
    
  end
end