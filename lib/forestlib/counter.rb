require 'set'

module ForestLib
  
  # Counts various graph properties based on input files with
  # unique (node,node) pairs or (node,count) pairs on each line
  
  class Counter
    
    # Takes (node,node) pairs and counts the total number of unique nodes
    def self.unique_nodes(input_file, idx1, idx2)
      idx1, idx2 = idx2, idx1 if idx1 > idx2
      split_limit = idx2 + 2
      
      nodes = Set.new
      
      print "Processing #{input_file} looking at token #{idx1} and #{idx2}..."
      
      File.open(input_file,"r").each do |l|
        parts = l.split(" ",split_limit)
        nodes.add parts[idx1].to_i
        nodes.add parts[idx2].to_i
      end
      
      # File.open(output_file,"w") do |f|
      #   f.puts nodes.count
      # end
      
      print "done\n"
      
      nodes.count
    end
    
    # Takes (node,node) pairs and generates degree counts for each node
    def self.degree_count(input_file, output_file, idx1, idx2)
      raise NotImplementedError, "Degree count isn't implemented yet"
    end
    
    # Takes (node,degreecount) pairs and generates degree counts for each node
    def self.degree_count_adder(input_file, output_file, idx1, idx2)
      raise NotImplementedError, "Degree count adder isn't implemented yet"
    end
    
  end
  
end