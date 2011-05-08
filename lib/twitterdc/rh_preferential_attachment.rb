require_relative 'twitterdc'
require_relative '../forestlib/processor'
include TwitterDc
include ForestLib

module TwitterDc
  module ReciprocityHeuristics

    module PreferentialAttachmentHelpers
      def hlp(e1, e2, type)
        if type == :rec
          (@degrees[e1]-1) * (@degrees[e2]-1)
        elsif @edge_type == :in
          @degrees[e1] * (@degrees[e2]-1)
        else
          (@degrees[e1]-1) * @degrees[e2]
        end
      end
      
      def hlp_directed(e1, e2, type)
        if type == :rec
          if @edge_type == :in
            (@degrees[e1]-1) * @degrees[e2]
          else
            @degrees[e1] * (@degrees[e2]-1)
          end
        else
          @degrees[e1] * @degrees[e2]
        end
      end
      
      def hlp_directed_onesided(e1,e2,type)
        if type == :rec && @edge_type == :out
          @degrees[e2] - 1
        else
          @degrees[e2]
        end
      end
    end

    class PreferentialAttachmentDecision
      include BaseDecisionHelpers
      include PreferentialAttachmentHelpers
  
      def initialize(c, edge_type=:in, degrees)
        @c = c
        @degrees = degrees
        @edge_type = edge_type
      end
    end

    class PreferentialAttachment < Base
      include BaseHelpers
      include PreferentialAttachmentHelpers
  
      def initialize(c, edge_type=:in)
        super(c)
        @degrees = case edge_type
        when :in then Processor.to_hash_float(@c.degrees)
        when :out then Processor.to_hash_float(@c.degrees, 0, 2)
        end
        @edge_type = edge_type
        @constants = Constant.new(c, "prefattach", [edge_type])
      end
  
      def self.constants(c, edge_type=:in)
        Constant.new(c, "prefattach", [edge_type])
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