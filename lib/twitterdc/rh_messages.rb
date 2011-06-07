require_relative 'twitterdc'
require_relative '../forestlib/processor'
include TwitterDc
include ForestLib

module TwitterDc
  module ReciprocityHeuristics
    
    module MessagesHelpers
      
      def hlp(e1,e2,type)
        d1, d2 = @messages[e1], @messages[e2]
        msgs_e1_e2 = @msgedges[[e1,e2]]
        msgs_e1_e2 ||= 0
        msgs_e2_e1 = @msgedges[[e2,e1]]
        msgs_e2_e1 ||= 0
        if @edge_type==:in
          d1 -= msgs_e2_e1
          d2 -= msgs_e1_e2
        else
          d1 -= msgs_e1_e2
          d2 -= msgs_e2_e1
        end
        r = d1 / d2
        r.nan? ? 0.0 : (r > 1 ? 1.0/r : r)
      end
      
      def hlp_directed(e1,e2,type)
        d1, d2 = @messages[e1], @messages[e2]
        msgs_e2_e1 = @msgedges[[e2,e1]]
        msgs_e2_e1 ||= 0
        if @edge_type==:in
          d1 -= msgs_e2_e1
        else
          d2 -= msgs_e2_e1
        end
        r = d1 / d2
        r.nan? ? 0.0 : r
      end
      
      def hlp_directed_onesided(e1,e2,type)
        msgs_e2_e1 = (@msgedges[[e2,e1]] || 0)
        d2 = @messages[e2]
        if @edge_type == :out
          d2 -= msgs_e2_e1
        end
        d2
      end
      
      def hlp_directed_v(e1,e2,type)
        msgs_e2_e1 = (@msgedges[[e2,e1]] || 0)
        d1 = @messages[e1]
        if @edge_type == :in
          d1 -= msgs_e2_e1
        end
        d1
      end
      
    end
    
    class MessagesDecision
      include MessagesHelpers
      include BaseDecisionHelpers
      
      def initialize(c, messages, msgedges, edge_type)
        @edge_type = edge_type
        @messages = messages
        @msgedges = msgedges
      end
      
    end
    
    class Messages < Base
      include BaseHelpers
      include MessagesHelpers
      
      def initialize(c, edge_type=:in)
        super(c)
        @edge_type = edge_type
        @messages = case edge_type
          when :in then Processor.to_hash_float(@c.people_msg, 0, 1)
          when :out then Processor.to_hash_float(@c.people_msg, 0, 2)
          end
        @msgedges = Processor.to_tuple_hash_float(@c.rur_msg_edges(@c.k))
        @constants = Constant.new(c, "msg", [edge_type])
      end
      
      def self.constants(c, edge_type=:in)
        Constant.new(c, "msg", [edge_type])
      end
      
      def output
        base_output &e_to_einv_proc(@inmessages)
      end
    end
    
  end
end