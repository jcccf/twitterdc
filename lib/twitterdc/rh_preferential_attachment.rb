require_relative 'twitterdc'
require_relative '../forestlib/processor'
include TwitterDc
include ForestLib

module TwitterDc
  module ReciprocityHeuristics

    module PreferentialAttachmentHelpers
      def hlp(e1, e2, type)
        if @direction == :v_to_w
          od1, id2 = @outdegrees[e1], @indegrees[e2]
          return 0 unless od1 && id2
          (od1-1) * (id2-1)
        else # :w_to_v
          id1, od2 = @indegrees[e1], @outdegrees[e2]
          return 0 unless id1 && od2
          if type == :rec
            (id1-1) * (od2-1)
          else
            id1 * od2
          end
        end
      end
      
      def hlp_directed(e1, e2, type)
        if @direction == :v_to_w
          od1, id2 = @outdegrees[e1], @indegrees[e2]
          return 0 unless od1 && id2
          od1 * id2
        else # :w_to_v
          id1, od2 = @indegrees[e1], @outdegrees[e2]
          return 0 unless id1 && od2
          if type == :rec
            (id1-1) * (od2-1)
          else
            id1 * od2
          end
        end
      end
      
      def hlp_directed_onesided(e1,e2,type)
        raise ArgumentError, "Pref Attachment doesn't do onesided predictions"
      end
    end

    class PreferentialAttachmentDecision
      include BaseDecisionHelpers
      include PreferentialAttachmentHelpers
  
      def initialize(c, indegrees, outdegrees, direction=:v_to_w)
        @c = c
        @indegrees = indegrees
        @outdegrees = outdegrees
        @direction = direction
      end
    end

    class PreferentialAttachment < Base
      include BaseHelpers
      include PreferentialAttachmentHelpers
  
      def initialize(c, direction=:v_to_w)
        super(c)
        @indegrees = Processor.to_hash_float(@c.degrees)
        @outdegrees = Processor.to_hash_float(@c.degrees, 0, 2)
        @direction = direction
        @constants = Constant.new(c, "prefattach", [direction])
      end
  
      def self.constants(c, direction=:v_to_w)
        Constant.new(c, "prefattach", [direction])
      end
  
      def output
        base_output do |e1,e2,type|
          product = @cache[e1][e2]
          product ||= (@cache[e1][e2] = preferential_attachment(e1,e2,type))
          if product >= @e * 1000
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