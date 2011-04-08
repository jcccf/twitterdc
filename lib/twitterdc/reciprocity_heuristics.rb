require_relative 'constants'
require_relative '../forestlib/processor'
include TwitterDc
include ForestLib

module TwitterDc
  module ReciprocityHeuristics
    
    # Base module that all heuristics MUST include
    module Helpers
      def base_output &edge_block
        File.open(@outfile+"~","w") do |f|
          # Step through each threshold
          @c.range_array.each do |j|
            @e = j / 100.0
            @e_inv = 1 / @e
            @rec_no, @rec_correct, @unr_no, @unr_correct = 0, 0, 0, 0
            @edges.each &edge_block
            f.puts "#{j} #{@rec_no} #{@rec_correct} #{@unr_no} #{@unr_correct} #{@edges.count}"
          end
        end
        File.rename(@outfile+"~",@outfile)
      end
      
      # Prediction based on whether the variable is between e and 1/e
      def e_to_einv_proc(my_var)
        Proc.new do |e1,e2,type|
          ratio = (my_var[e1] && my_var[e2]) ? my_var[e1]/my_var[e2] : 0
          # For each edge, predict reciprocity, rec_no += 1
          # If the edge was reciprocated, correct += 1
          if @e <= ratio && ratio <= @e_inv
            @rec_no += 1
            @rec_correct += 1 if type == 2
          else
            @unr_no += 1
            @unr_correct += 1 if type == 1
          end
        end
      end
    end
    
    # Base class that all heuristics inherit from
    class Base
      def initialize(i,c,edges)
        @i = i
        @c = c
        @edges = edges
      end
    end
    
    class Indegree < Base
      include Helpers
      
      def initialize(i,c,edges)
        super
        @indegrees = Processor.to_hash_float(@c.degrees)
        @outfile = @c.rur_pred_degree(@i)
      end
      
      def self.image
        @c.rur_pred_degree_image(@i)
      end
      
      def self.outfile
        @c.rur_pred_degree
      end
      
      def output
        base_output &e_to_einv_proc(@indegrees)
      end
    end
    
    class Inmessages < Base
      include Helpers
      
      def initialize(i,c,edges)
        super
        @inmessages = Processor.to_hash_float(@c.people_msg, 0, 1)
        @outfile = @c.rur_pred_inmsg(@i)
      end
      
      def self.image
        @c.rur_pred_inmsg_image(@i)
      end
      
      def self.outfile
        @c.rur_pred_inmsg
      end
      
      def output
        base_output &e_to_einv_proc(@inmessages)
      end
    end
    
    class Outmessages < Base
      include Helpers
      
      def initialize(i,c,edges)
        super
        @outmessages = Processor.to_hash_float(@c.people_msg, 0, 1)
        @outfile = @c.rur_pred_outmsg(@i)
      end
      
      def self.image
        @c.rur_pred_outmsg_image(@i)
      end
      
      def self.outfile
        @c.rur_pred_outmsg
      end
      
      def output
        base_output &e_to_einv_proc(@outmessages)
      end
    end
    
    class MessagesPerDegree < Base
      include Helpers
      
      def initialize(i,c,edges)
        super
        msgs = Processor.to_hash_float(@c.people_msg, 0, 1)
        degs = Processor.to_hash_float(@c.degrees)
        @msgdeg = degs.merge(msgs){ |k,deg,msg| msg/deg }
        @outfile = @c.rur_pred_msgdeg(@i)
      end
      
      def self.image
        @c.rur_pred_msgdeg_image(@i)
      end
      
      def self.outfile
        @c.rur_pred_msgdeg
      end
      
      def output
        base_output &e_to_einv_proc(@msgdeg)
      end
    end
    
    class OutdegreePerIndegree < Base
      include Helpers
      
      def initialize(i,c,edges)
        super
        @outindeg = Processor.to_hash_float_block(@c.degrees, 0, 1, 2) { |indeg,outdeg| outdeg/indeg }
        @outfile = @c.rur_pred_inoutdeg(@i)
      end
      
      def self.image
        @c.rur_pred_inoutdeg_image(@i)
      end
      
      def self.outfile
        @c.rur_pred_inoutdeg
      end
      
      def output
        base_output &e_to_einv_proc(@outindeg)
      end
    end
    
    class MutualInJaccard < Base
      include Helpers
      
      def initialize(i,c,edges)
        super
        @all_edges = Processor.to_hash_array(@c.edges, 1, 0) # Reverse
        @outfile = @c.rur_pred_mutualin_nbrs(@i)
      end
      
      def self.image
        @c.rur_pred_mutualin_nbrs_image(@i)
      end
      
      def self.outfile
        @c.rur_pred_mutualin_nbrs
      end
      
      def output
        base_output do |e1,e2,type|
          num_mutual = (@all_edges[e1] && @all_edges[e2]) ? (@all_edges[e1] & @all_edges[e2]).size : 0
          total_nbrs = ((@all_edges[e1] ? @all_edges[e1] : []) | (@all_edges[e2] ? @all_edges[e2] : [])).size
          if total_nbrs == 0 || (num_mutual / (total_nbrs-0.0)) >= @e
            @rec_no += 1
            @rec_correct += 1 if type == 2
          else
            @unr_no += 1
            @unr_correct += 1 if type == 1
          end
        end
      end
    end
    
    class MutualInAbsolute < Base
      include Helpers
      
      def initialize(i,c,edges)
        super
        @all_edges = Processor.to_hash_array(@c.edges, 1, 0) # Reverse
        @outfile = @c.rur_pred_mutualin_abs(@i)
      end
      
      def self.image
        @c.rur_pred_mutualin_abs_image(@i)
      end
      
      def self.outfile
        @c.rur_pred_mutualin_abs
      end
      
      def output
        base_output do |e1,e2,type|
          num_mutual = (@all_edges[e1] && @all_edges[e2]) ? (@all_edges[e1] & @all_edges[e2]).size : 0
          if num_mutual >= @e * 100
            @rec_no += 1
            @rec_correct += 1 if type == 2
          else
            @unr_no += 1
            @unr_correct += 1 if type == 1
          end
        end
      end
    end
    
    class MutualInAdamic < Base
      include Helpers
      
      def initialize(i,c,edges)
        super
        @indegrees = Processor.to_hash_float(@c.degrees)
        @all_edges = Processor.to_hash_array(@c.edges, 1, 0) # Reverse
        @outfile = @c.rur_pred_mutualin_wnbrs(@i)
        @ehash = Hash.new({})
      end
      
      def self.image
        @c.rur_pred_mutualin_wnbrs_image(@i)
      end
      
      def self.outfile
        @c.rur_pred_mutualin_wnbrs
      end
      
      def output
        base_output do |e1,e2,type|
          #puts "Testing %d against %d" % [e1,e2]
          mutual = (@all_edges[e1] ? @all_edges[e1] : []) & (@all_edges[e2] ? @all_edges[e2] : [])
          # Use cached values if they exist
          score = if @ehash[e1][e2]
            @ehash[e1][e2]
          else
            s = 0.0
            mutual.each { |m| s += 1.0 / Math.log(@indegrees[m]) if @indegrees[m] }
            @ehash[e1][e2] = s
          end
          if score >= @e * 100
            @rec_no += 1
            @rec_correct += 1 if type == 2
          else
            @unr_no += 1
            @unr_correct += 1 if type == 1
          end
        end
      end
    end
    
    class KatzNStep < Base
      include Helpers
      
      def initialize(i,c,edges,n=2)
        super
        @outfile = @c.ASDASD(@i)
        @ehash = Hash.new({})
        raise NotImplementedException, "Not yet!"
      end
      
      def self.image
        @c.ASDASD_image(@i)
      end
      
      def self.outfile
        @c.ASDASD
      end
      
      def output
        base_output do |e1,e2,type|
          #
      end
    end
    
  end
end