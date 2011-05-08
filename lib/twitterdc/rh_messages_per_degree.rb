require_relative 'twitterdc'
require_relative '../forestlib/processor'
include TwitterDc
include ForestLib

module TwitterDc
  module ReciprocityHeuristics
    
    module MessagesPerDegreeHelpers
      
      def hlp(e1,e2,type)
        e1msg, e1deg, e2msg, e2deg = @msgs[e1], @degs[e1], @msgs[e2], @degs[e2]
        msgs_e1_e2 = (@msgedges[[e1,e2]] || 0)
        msgs_e2_e1 = (@msgedges[[e2,e1]] || 0)
        if type == :rec
          e1deg -= 1
          e2deg -= 1
        else
          if @edge_type == :in
            e2deg -= 1
          else
            e1deg -= 1
          end
        end
        if @edge_type==:in
          e1msg -= msgs_e2_e1
          e2msg -= msgs_e1_e2
        else
          e1msg -= msgs_e1_e2
          e2msg -= msgs_e2_e1
        end
        r = (e1msg / e1deg) / (e2msg / e2deg)
        r.nan? ? 0.0 : (r > 1 ? 1.0/r : r)
      end
      
      def hlp_directed(e1,e2,type)
        e1msg, e1deg, e2msg, e2deg = @msgs[e1], @degs[e1], @msgs[e2], @degs[e2]
        msgs_e2_e1 = (@msgedges[[e2,e1]] || 0)
        if type == :rec
          if @edge_type == :in
            e1deg -= 1
          else
            e2deg -= 1
          end
        end
        if @edge_type==:in
          e1msg -= msgs_e2_e1
        else
          e2msg -= msgs_e2_e1
        end
        r = (e1msg / e1deg) / (e2msg / e2deg)
        r.nan? ? 0.0 : (r > 1 ? 1.0/r : r)        
      end
      
      def hlp_directed_onesided(e1,e2,type)
        e2msg, e2deg = @msgs[e2], @degs[e2]
        msgs_e2_e1 = (@msgedges[[e2,e1]] || 0)
        if @edge_type == :out
          e2deg -= 1 if type == :rec
          e2msg -= msgs_e2_e1
        end
        r = e2msg / e2deg
        r.nan? ? 0.0 : r
      end
      
    end
    
    class MessagesPerDegreeDecision
      include MessagesPerDegreeHelpers
      include BaseDecisionHelpers
      
      def initialize(c, msgs, degs, msgedges, edge_type)
        @msgs = msgs
        @degs = degs
        @msgedges = msgedges
        @edge_type = edge_type
      end
      
    end
    
    class MessagesPerDegree < Base
      include BaseHelpers
      include MessagesPerDegreeHelpers
      
      def initialize(c,edge_type=:in)
        super(c)
        @edge_type = :in
        @msgs = case edge_type
          when :in then Processor.to_hash_float(@c.people_msg, 0, 1)
          when :out then Processor.to_hash_float(@c.people_msg, 0, 2)
          end
        @degs = case edge_type
          when :in then Processor.to_hash_float(@c.degrees)
          when :out then Processor.to_hash_float(@c.degrees, 0, 2)
          end
        @msgedges = Processor.to_tuple_hash_float(@c.rur_msg_edges(@c.k))
        @constants = Constant.new(c, "msgdeg", [edge_type])
      end
      
      def self.constants(c, edge_type=:in)
        Constant.new(c, "msgdeg", [edge_type])
      end
      
      def output
        base_output &e_to_einv_proc(@msgdeg)
      end
    end
    
  end
end