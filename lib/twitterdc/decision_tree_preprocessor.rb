require_relative 'twitterdc'
require_relative '../forestlib/processor'
include TwitterDc
include ForestLib

module TwitterDc
  class DecisionTreePreprocessor
    
    def initialize(c, i, prefix, edges)
      @c = c
      @i = i
      @names = []
      @edges = edges
      @classifier = ReciprocityHeuristics::Classifier.new
      @csv_test = "csv_test_" + prefix
      @csv_training = "csv_training_" + prefix
      @csv_transitions = "csv_transitions_" + prefix
    end
    
    def percentiles_for(name,fun)
      raise "Repeated symbol passed to percentiles_for, #{name.to_s}" if @names.include? name
      @names << name
      vals = {}
      puts "Calculating values for #{name.to_s}..."
      @edges.each do |e1,e2,type|
        vals[[e1,e2]] = fun.result_directed(e1,e2,type)
      end
      puts "Classifying values for #{name.to_s}..."
      @classifier.percentiles(name,vals)
    end
    
    def percentiles_for_sym(name,fun)
      raise "Repeated symbol passed to percentiles_for, #{name.to_s}" if @names.include? name
      @names << name
      vals = {}
      puts "Calculating values for #{name.to_s}..."
      @edges.each do |e1,e2,type|
        vals[[e1,e2]] = fun.result(e1,e2,type)
      end
      puts "Classifying values for #{name.to_s}..."
      @classifier.percentiles(name,vals)
    end
    
    def percentiles_for_w(name,fun)
      raise "Repeated symbol passed to percentiles_for, #{name.to_s}" if @names.include? name
      @names << name
      vals = {}
      puts "Calculating values for #{name.to_s}..."
      @edges.each do |e1,e2,type|
        vals[[e1,e2]] = fun.result_directed_onesided(e1,e2,type)
      end
      puts "Classifying values for #{name.to_s}..."
      @classifier.percentiles(name,vals)
    end
    
    def percentiles_for_v(name,fun)
      raise "Repeated symbol passed to percentiles_for, #{name.to_s}" if @names.include? name
      @names << name
      vals = {}
      puts "Calculating values for #{name.to_s}..."
      @edges.each do |e1,e2,type|
        vals[[e1,e2]] = fun.result_directed_v(e1,e2,type)
      end
      puts "Classifying values for #{name.to_s}..."
      @classifier.percentiles(name,vals)
    end
    
    def output
      # Generate label array
      label_array = @names.inject([]) { |a,name| a << name.to_s }
      label_array << 'reciprocated'
      
      # Write edge classifications
      puts "Writing output..."
      j = 0
      halfway = @edges.count/2 - 1
      CSV.open(Constant.new(@c,@csv_test).filename(@i)+"~", "w") do |csv_test|
        CSV.open(Constant.new(@c,@csv_training).filename(@i)+"~", "w") do |csv|
          csv << label_array
          csv_test << label_array
          @edges.each do |e1,e2,type|
            e = @classifier.classified[[e1,e2]]
            row = @names.inject([]) { |a,name| a << e[name] }
            row << ((type == :unr) ? 'N' : 'Y')
            (j <= halfway) ? csv << row : csv_test << row
            j += 1
          end
          
        end
      end
      
      # Rename output files
      File.rename(Constant.new(@c,@csv_test).filename(@i)+"~",Constant.new(@c,@csv_test).filename(@i))
      File.rename(Constant.new(@c,@csv_training).filename(@i)+"~",Constant.new(@c,@csv_training).filename(@i))
      
      # Print transitions
      File.open(Constant.new(@c,@csv_transitions).filename(@i),"w") do |f|
        @classifier.print_transitions(f)
      end
      
    end
    
  end
end