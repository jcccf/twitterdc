require_relative 'twitterdc'
require_relative '../forestlib/processor'
include TwitterDc
include ForestLib
require_relative 'rh_base'
require_relative 'rh_outdegree_per_indegree'
require_relative 'rh_katz'
require_relative 'rh_pagerank'
require_relative 'rh_preferential_attachment'

module TwitterDc
  module ReciprocityHeuristics
    
    class Indegree < Base
      include BaseHelpers
      
      def initialize(c)
        super
        @indegrees = Processor.to_hash_float(@c.degrees)
        @constants = Constant.new(c, "degree")
      end
      
      def self.constants(c)
        Constant.new(c, "degree")
      end
      
      def output
        base_output &e_to_einv_proc(@indegrees)
      end
    end
    
    class Inmessages < Base
      include BaseHelpers
      
      def initialize(c)
        super
        @inmessages = Processor.to_hash_float(@c.people_msg, 0, 1)
        @constants = Constant.new(c, "inmsg")
      end
      
      def self.constants(c)
        Constant.new(c, "inmsg")
      end
      
      def output
        base_output &e_to_einv_proc(@inmessages)
      end
    end
    
    class Outmessages < Base
      include BaseHelpers
      
      def initialize(c)
        super
        @outmessages = Processor.to_hash_float(@c.people_msg, 0, 2)
        @constants = Constant.new(c, "outmsg")
      end
      
      def self.constants(c)
        Constant.new(c, "outmsg")
      end
      
      def output
        base_output &e_to_einv_proc(@outmessages)
      end
    end
    
    class MessagesPerDegree < Base
      include BaseHelpers
      
      def initialize(c)
        super
        msgs = Processor.to_hash_float(@c.people_msg, 0, 1)
        degs = Processor.to_hash_float(@c.degrees)
        @msgdeg = degs.merge(msgs){ |k,deg,msg| msg/deg }
        @constants = Constant.new(c, "msgdeg")
      end
      
      def self.constants(c)
        Constant.new(c, "msgdeg")
      end
      
      def output
        base_output &e_to_einv_proc(@msgdeg)
      end
    end
    

    
    class MutualInJaccard < Base
      include BaseHelpers
      
      def initialize(c)
        super
        @all_edges = Processor.to_hash_array(@c.edges, 1, 0) # Reverse
        @constants = Constant.new(c, "mutualin_nbrs")
      end
      
      def self.constants(c)
        Constant.new(c, "mutualin_nbrs")
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
    
    class MutualInAbsolute < Base
      include BaseHelpers
      
      def initialize(c)
        super
        @all_edges = Processor.to_hash_array(@c.edges, 1, 0) # Reverse
        @constants = Constant.new(c, "mutualin_abs")
      end
      
      def self.constants(c)
        Constant.new(c, "mutualin_abs")
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
    
    module MutualInAdamicHelpers
      def weighted_score(e1,e2,type)
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
    end
    
    class MutualInAdamicDecision
      include MutualInAdamicHelpers
      
      def initialize(c,outdegrees,all_edges)
        @c = c
        @outdegrees = outdegrees
        @all_edges = all_edges
      end
      
      def result(e1,e2,type)
        weighted_score(e1,e2,type)
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
      
      def output_percentiles
        base_output_percentiles_100 do |e1,e2,type|
          weighted_score(e1,e2,type)
        end
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

# c = ReciprocityHeuristics::RootedPagerank.constants(Constants.new("abc",500,10,30))
# e = {1 => [2,5], 5=>[3], 2 => [3,4]}
# x = ReciprocityHeuristics::KatzNStepDecision.new(c,e)
# puts x.result(1,3)