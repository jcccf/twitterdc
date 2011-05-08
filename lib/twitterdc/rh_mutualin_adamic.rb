require_relative 'twitterdc'
require_relative '../forestlib/processor'
include TwitterDc
include ForestLib

module TwitterDc
  module ReciprocityHeuristics
    
    module MutualInAdamicHelpers
      def hlp(e1,e2,type)
        if type == :rec
          mutual = (@all_edges[e1] ? @all_edges[e1] - [e2] : []) & (@all_edges[e2] ? @all_edges[e2] - [e1] : [])
          s = 0.0
          mutual.each { |m| s += 1.0 / Math.log(@outdegrees[m]) if @outdegrees[m] }
          s
        else
          mutual = (@all_edges[e1] ? @all_edges[e1] : []) & (@all_edges[e2] ? @all_edges[e2] - [e1] : [])
          s = 0.0
          mutual.each { |m| s += 1.0 / Math.log(@outdegrees[m]) if @outdegrees[m] }
          s
        end
      end
      
      def hlp_directed(e1,e2,type)
        if type == :rec
          mutual = (@all_edges[e1] ? @all_edges[e1] - [e2] : []) & (@all_edges[e2] ? @all_edges[e2] : [])
          s = 0.0
          mutual.each { |m| s += 1.0 / Math.log(@outdegrees[m]) if @outdegrees[m] }
          s
        else
          mutual = (@all_edges[e1] ? @all_edges[e1] : []) & (@all_edges[e2] ? @all_edges[e2] : [])
          s = 0.0
          mutual.each { |m| s += 1.0 / Math.log(@outdegrees[m]) if @outdegrees[m] }
          s
        end
      end
      
      def hlp_directed_onesided(e1,e2,type)
        raise ArgumentError, "MutualInAdamic does not care about onesided"
      end
    end
    
    class MutualInAdamicDecision
      include MutualInAdamicHelpers
      include BaseDecisionHelpers
      
      def initialize(c,outdegrees,all_edges)
        @c = c
        @outdegrees = outdegrees
        @all_edges = all_edges
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
          score ||= (@cache[e1][e2] = weighted_score(e1,e2,type))
          if score >= @e * 100
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