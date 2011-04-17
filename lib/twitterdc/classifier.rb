module TwitterDc
  module ReciprocityHeuristics
    
    class Classifier
      
      attr_reader :classified, :transitions
      
      def initialize
        @classified = Hash.new {|h,k| h[k] = {}}
        @transitions = Hash.new {|h,k| h[k] = {}}
      end
      
      # Classifies hash keys into 10 bins based on its values
      # (0<=x<=10th percentile, ..., 90<x<=100 percentile)
      # Ex. {"h" => 1, "w" => 2} returns {"h" => 50, "w" => 100}
      def percentiles(name, values)
        puts "Classifying %s into percentiles..." % name
        sorted = values.sort{|a,b| a[1] <=> b[1]}
        i, max, pct = 1, sorted.count.to_f, {}
        c = 0
        sorted.each do |k,v|
          p = (i/max*10).ceil * 10
          @classified[k][name] = p
          if c != p
            @transitions[name][p] = v
            c = p
          end
          i += 1
        end
        puts values
        puts @classified
        self
      end
      
      def print_transitions(io)
        @transitions.each do |k,v|
          io.puts k
          v.each do |k,v|
            io.puts "\t #{k} \t #{v}"
          end
          io.puts
        end
      end
      
      # Classifies a single value that ranges from -infty to +infty
      def self.e_to_e_inverse(ratio)
        (0..10).each do |i|
          e = 1 - i/10.0
          if e <= ratio && ratio <= 1/e
            return sprintf("%.1f", e)
          end
        end
      end
      
      # Classifies a single value that ranges from 0-1
      def self.zero_to_one(ratio)
        return sprintf("%.1f", (ratio*10).floor/10.0)
        # (0..10).each do |i|
        #   e = 1 - i/10.0
        #   if ratio >= e
        #     return sprintf("%.1f", e)
        #   end
        # end
      end
      
      # Classifies a single value that ranges from 0-100
      def self.zero_to_hundred(ratio)
        return sprintf("%d",(ratio/10).floor*10)
        # (0..100).step(10) do |i|
        #           e = 100 - i
        #           if ratio >= e
        #             return sprintf("%d", e)
        #           end
        #         end
      end
      
    end
    
  end
end