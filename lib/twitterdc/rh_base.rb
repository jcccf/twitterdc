require_relative 'twitterdc'
require_relative '../forestlib/processor'
include TwitterDc
include ForestLib

module TwitterDc
  module ReciprocityHeuristics

    class Helpers
  
      # Read in reciprocated and unreciprocated edges and create a combined edge list with
      # equal proportions of reciprocated and unreciprocated edges by choosing a random number
      # of edges from the reciprocated graph equal to the number of edges in the unreciprocated
      # graph. If balanced is set to false then just return all edges
      def self.read_rur_edges(unr_filename, rec_filename, balanced=true, directed=false)

        dupchecker = Set.new

        # Read in Unreciprocated Edges
        puts "Reading in Unreciprocated Edges"
        edges = []
        File.open(unr_filename,"r").each do |l|
          e1, e2 = l.split.map!{|v| v.to_i }
          e1x, e2x = (e1 > e2) ? [e2, e1] : [e1, e2]
          raise RuntimeError "Not supposed to exist" if dupchecker.include? [e1x,e2x]
          dupchecker.add [e1, e2]
          edges << [e1, e2, :unr] # The order of e1, e2 matters!
        end

        # Read in Reciprocated Edges
        puts "Reading in Reciprocated Edges"
        tmp_edges = []
        File.open(rec_filename,"r").each do |l|
          e1, e2 = l.split.map!{|v| v.to_i }
          e1, e2 = e2, e1 if e1 > e2
          raise RuntimeError "Not supposed to exist" if dupchecker.include? [e1,e2]
          dupchecker.add [e1, e2]
          if directed
            tmp_edges << ([e1,e2].shuffle << :rec)
          else
            tmp_edges << [e1, e2, :rec]
          end
        end

        # Take N random entries from the reciprocated edge list 
        # where N = # of unreciprocated edges
        if balanced
          edges = edges | (tmp_edges.sort_by{rand}[0..(edges.count-1)])
        else
          edges = edges | tmp_edges
        end
        edges
      end
    end

    # Base module that all heuristics MUST include
    module BaseHelpers
      def base_output &edge_block
        @c.unreciprocated do |i,unr_filename|
          outfile = @constants.filename(i)
          edges = Helpers.read_rur_edges(unr_filename, @c.reciprocated_norep(i))
          File.open(outfile+"~","w") do |f|
            # Step through each threshold
            @c.range_array.each do |j|
              @e = j / 100.0
              @e_inv = 1 / @e
              @rec_no, @rec_correct, @unr_no, @unr_correct = 0, 0, 0, 0
              edges.each &edge_block
              f.puts "#{j} #{@rec_no} #{@rec_correct} #{@unr_no} #{@unr_correct} #{edges.count}"
            end
          end
          File.rename(outfile+"~",outfile)
        end
      end
  
      def base_output_percentiles_100 &edge_block
        @c.unreciprocated do |i,unr_filename|
          outfile = @constants.pfilename(i)
          outfile_opp = @constants.pfilename_opp(i)
          edges = Helpers.read_rur_edges(unr_filename, @c.reciprocated_norep(i))
          p = ReciprocityHeuristics::Classifier.new
          edgevals = {}
          edges.each do |e1,e2,type|
            edgevals[[e1,e2]] = edge_block.call(e1,e2,type)
          end
      
          p.percentiles100(:a, edgevals)
      
          # Print percentile transitions
          File.open(@constants.pfilename_trans(i),"w") do |f|
            p.print_transitions(f)
          end
          
          File.open(outfile_opp+"~","w") do |f2|
            File.open(outfile+"~","w") do |f|
              # Step through each threshold
              @c.range_array_full.each do |j|
                @e = j
                @rec_no, @rec_correct, @unr_no, @unr_correct = 0, 0, 0, 0
                edges.each do |e1,e2,type|
                  val = p.classified[[e1,e2]][:a]
                  if val >= @e
                    @rec_no += 1
                    @rec_correct += 1 if type == :rec
                  else
                    @unr_no += 1
                    @unr_correct += 1 if type == :unr
                  end
                end
                f.puts "#{j} #{@rec_no} #{@rec_correct} #{@unr_no} #{@unr_correct} #{edges.count}"
                # Equivalent to unr_no, Unr_correct, rec_no, rec_correct
                f2.puts "#{j} #{@rec_no} #{@rec_no - @rec_correct} #{@unr_no} #{@unr_no - @unr_correct} #{edges.count}"
              end
            end
          end
          File.rename(outfile+"~",outfile)
          File.rename(outfile_opp+"~",outfile_opp)
        end
      end
  
      def base_output_directed_percentiles_100 &edge_block
        @c.unreciprocated do |i,unr_filename|
          outfile = @constants.dir_pfilename(i)
          outfile_opp = @constants.dir_pfilename_opp(i)
          edges = Helpers.read_rur_edges(unr_filename, @c.reciprocated_norep(i), true, true)
          p = ReciprocityHeuristics::Classifier.new
          edgevals = {}
          edges.each do |e1,e2,type|
            edgevals[[e1,e2]] = edge_block.call(e1,e2,type)
          end
      
          p.percentiles100(:a, edgevals)
          
          # Print percentile transitions
          File.open(@constants.dir_pfilename_trans(i),"w") do |f|
            p.print_transitions(f)
          end
      
          File.open(outfile_opp+"~","w") do |f2|
            File.open(outfile+"~","w") do |f|
              # Step through each threshold
              @c.range_array_full.each do |j|
                @e = j
                @rec_no, @rec_correct, @unr_no, @unr_correct = 0, 0, 0, 0
                edges.each do |e1,e2,type|
                  val = p.classified[[e1,e2]][:a]
                  #puts "%d %d" % [@e, val]
                  if val >= @e
                    @rec_no += 1
                    @rec_correct += 1 if type == :rec
                  else
                    @unr_no += 1
                    @unr_correct += 1 if type == :unr
                  end
                end
                f.puts "#{j} #{@rec_no} #{@rec_correct} #{@unr_no} #{@unr_correct} #{edges.count}"
                f2.puts "#{j} #{@rec_no} #{@rec_no - @rec_correct} #{@unr_no} #{@unr_no - @unr_correct} #{edges.count}"
              end
            end
          end
          File.rename(outfile+"~",outfile)
          File.rename(outfile_opp+"~",outfile_opp)
        end
      end
      
      def base_output_directed_onesided_percentiles_100 &edge_block
        @c.unreciprocated do |i,unr_filename|
          outfile = @constants.diro_pfilename(i)
          outfile_opp = @constants.diro_pfilename_opp(i)
          edges = Helpers.read_rur_edges(unr_filename, @c.reciprocated_norep(i), true, true)
          p = ReciprocityHeuristics::Classifier.new
          edgevals = {}
          edges.each do |e1,e2,type|
            edgevals[[e1,e2]] = edge_block.call(e1,e2,type)
          end
      
          p.percentiles100(:a, edgevals)
          
          # Print percentile transitions
          File.open(@constants.diro_pfilename_trans(i),"w") do |f|
            p.print_transitions(f)
          end
      
          File.open(outfile_opp+"~","w") do |f2|
            File.open(outfile+"~","w") do |f|
              # Step through each threshold
              @c.range_array_full.each do |j|
                @e = j
                @rec_no, @rec_correct, @unr_no, @unr_correct = 0, 0, 0, 0
                edges.each do |e1,e2,type|
                  val = p.classified[[e1,e2]][:a]
                  #puts "%d %d" % [@e, val]
                  if val >= @e
                    @rec_no += 1
                    @rec_correct += 1 if type == :rec
                  else
                    @unr_no += 1
                    @unr_correct += 1 if type == :unr
                  end
                end
                f.puts "#{j} #{@rec_no} #{@rec_correct} #{@unr_no} #{@unr_correct} #{edges.count}"
                f2.puts "#{j} #{@rec_no} #{@rec_no - @rec_correct} #{@unr_no} #{@unr_no - @unr_correct} #{edges.count}"
              end
            end
          end
          File.rename(outfile+"~",outfile)
          File.rename(outfile_opp+"~",outfile_opp)
        end
      end
  
      # Prediction based on whether the variable is between e and 1/e
      def e_to_einv_proc(my_var)
        Proc.new do |e1,e2,type|
          ratio = (my_var[e1] && my_var[e2]) ? my_var[e1]/my_var[e2] : 0
          # For each edge, predict reciprocity, rec_no += 1
          # If the edge was reciprocated, correct += 1
          if @e <= ratio && ratio <= @e_inv
            @rec_no += 1
            @rec_correct += 1 if type == :rec
          else
            @unr_no += 1
            @unr_correct += 1 if type == :unr
          end
        end
      end
    end

    # Base class that all heuristics inherit from
    class Base
      def initialize(c)
        @c = c
        @cache = Hash.new {|h,k| h[k] = {}}
        @pref_cache = Hash.new {|h,k| h[k] = {}}
      end
      
      def clear_cache
        @cache = Hash.new {|h,k| h[k] = {}}
      end
      
      def output_percentiles
        clear_cache
        base_output_percentiles_100 do |e1,e2,type|
          #puts "For #{e1} #{e2} #{type} value is #{r}"
          r = @cache[e1][e2]
          r ||= (@cache[e1][e2] = hlp(e1,e2,type))
        end
      end
  
      def output_directed_percentiles
        clear_cache
        base_output_directed_percentiles_100 do |e1,e2,type|
          #puts "For dir #{e1} #{e2} #{type} value is #{r}"
          r = @cache[e1][e2]
          r ||= (@cache[e1][e2] = hlp_directed(e1,e2,type))
        end
      end
      
      def output_directed_onesided_percentiles
        clear_cache
        base_output_directed_onesided_percentiles_100 do |e1,e2,type|
          #puts "For dir one #{e1} #{e2} #{type} value is #{r}"
          r = @cache[e1][e2]
          r ||= (@cache[e1][e2] = hlp_directed_onesided(e1,e2,type))
        end
      end
    end
    
    module BaseDecisionHelpers
      def result(e1,e2,type)
        hlp(e1,e2,type)
      end
      
      def result_directed(e1,e2,type)
        hlp_directed(e1,e2,type)
      end
      
      def result_directed_onesided(e1,e2,type)
        hlp_directed_onesided(e1,e2,type)
      end
    end
    
  end
end