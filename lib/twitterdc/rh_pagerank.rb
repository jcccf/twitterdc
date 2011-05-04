require_relative 'twitterdc'
require_relative '../forestlib/processor'
include TwitterDc
include ForestLib

module TwitterDc
  module ReciprocityHeuristics

    module RootedPagerankHelpers
      # Run rooted pagerank for n iterations with root e1
      # With probability @a, return to e1, with probability 1-@a, jump to a random node
      def run_iterations(e1,e2,n = 1000)
        puts "Running Rooted Pagerank for (#{e1},#{e2})..."
        a = @a
        ap = 1.0 - @a
        w = Hash.new(0.0)
        w[e1] = 1.0
        n.times do |i|
          (puts "%f %f" % [i, w[e2]]) if i % 50 == 0
          w_new = Hash.new(0.0)
          w.each do |k,v|
            w_new[e1] += a * v
            if @all_edges[k]
              w_new[@all_edges[k].sample] += ap * v
            else
              w_new[k] += ap * v
            end
          end
          w = w_new
        end
        #puts w.inspect
        w[e2]
      end
    end

    class RootedPagerankDecision
      include RootedPagerankHelpers
  
      def initialize(c,all_edges,alpha=0.15)
        @c = c
        @all_edges = all_edges
        @a = alpha
      end
  
      def result(e1,e2,type)
        run_iterations(e1,e2)
      end
  
    end

    class RootedPagerank < Base
      include BaseHelpers
      include RootedPagerankHelpers
  
      def initialize(c,edge_type=:in,alpha=0.15)
        super(c)
        @a = alpha
        @edge_type = edge_type
        @all_edges = case edge_type
          when :in then Processor.to_hash_array(@c.edges, 1, 0) # Reverse (receiver => sender)
          when :out then Processor.to_hash_array(@c.edges) # Directed edges, sender => receiver
          end
        @constants = Constant.new(c, "pagerank", [edge_type,alpha])
      end
  
      def self.constants(c, edge_type=:in, alpha=0.15)
        Constant.new(c, "pagerank", [edge_type,alpha])
      end
  
      def output
        base_output do |e1,e2,type|
          e2_stationary = @cache[e1][e2]
          e2_stationary ||= (@cache[e1][e2] = run_iterations(e1,e2))
          if e2_stationary >= @e
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