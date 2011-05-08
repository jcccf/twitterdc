module ForestLib
  # Converts files into hashes and so on.
  # Only handles integers
  class Processor
    
    # Converts "a b" on each line of a file into "a => b" mappings
    def self.to_hash(input_file, index_1 = 0, index_2 = 1)
      self.validate(input_file)
      maxsplit = [index_1, index_2].max + 1
      h = {}
      File.open(input_file,"r").each do |l|
        parts = l.split(" ", maxsplit)
        h[parts[index_1].to_i] = parts[index_2].to_i
      end
      h
    end
    
    # Converts "a b" on each line of a file into "a => b" mappings, but cast b as a float
    def self.to_hash_float(input_file, index_1 = 0, index_2 = 1)
      self.validate(input_file)
      maxsplit = [index_1, index_2].max + 1
      h = {}
      File.open(input_file,"r").each do |l|
        parts = l.split(" ", maxsplit)
        h[parts[index_1].to_i] = parts[index_2].to_f
      end
      h
    end
    
    # Converts "a b c" on each line of a file into "[a,b] => c" mappings, but cast c as a float
    def self.to_tuple_hash_float(input_file, index_1 = 0, index_2 = 1, index_3 = 2)
      self.validate(input_file)
      maxsplit = [index_1, index_2, index_3].max + 1
      h = {}
      File.open(input_file,"r").each do |l|
        parts = l.split(" ", maxsplit)
        h[[parts[index_1].to_i,parts[index_2].to_i]] = parts[index_3].to_f
      end
      h
    end
    
    # Converts "a b" on each line into "a => [b1,...,bn]" mappings
    # If directed is set to false, then mappings are "a => [b1,...,bn]" and "b => [a1,...,an]"
    def self.to_hash_array(input_file, index_1 = 0, index_2 = 1, directed = true)
      self.validate(input_file)
      maxsplit = [index_1, index_2].max + 1
      h = {}
      if directed
        File.open(input_file,"r").each do |l|
          parts = l.split(" ", maxsplit)
          i1, i2 = parts[index_1].to_i, parts[index_2].to_i
          h[i1] ||= []
          h[i1] << i2
        end
      else
        File.open(input_file,"r").each do |l|
          parts = l.split(" ", maxsplit)
          i1, i2 = parts[index_1].to_i, parts[index_2].to_i
          h[i1] ||= []
          h[i2] ||= []
          if !h[i1].include? i2 # Don't add (a,b) and then (b,a)
            h[i1] << i2
            h[i2] << i1
          end
        end
      end
      #puts h.inspect
      h
    end
    
    # Converts a line into an "a => b" mapping, with "b" a float.
    # b is calculated using the block provided to the method
    # the method is provided with arguments corresponding to the indices
    # provided after index_1.
    # Ex. to_hash_float_block("test.txt", 1, 3, 4) { |x,y| x*y } returns
    # mappings of the integer at index 1 on each line to the product of the integers
    # at indices 3 and 4. If a line is "1 2 3 4 5", this gets mapped to 2 => 20
    def self.to_hash_float_block(input_file, index_1, *args)
      # TODO Check if args are all integers
      
      raise ArgumentError, "Provide a Block Please!" if !block_given?
      
      num_vars = args.count
      self.validate(input_file)
      maxsplit = [args.max, index_1].max + 1
      h = {}
      File.open(input_file,"r").each do |l|
        parts = l.split(" ", maxsplit)
        yield_args = []
        args.each { |idx| yield_args << parts[idx].to_f }
        h[parts[index_1].to_i] = yield yield_args
      end
      h
    end
    
    private
    
    # Validate each token as an integer
    def self.validate(input_file)
      File.open(input_file,"r") do |f|
        while l = f.gets
          parts = l.split
          parts.each do |p|
            raise RuntimeException, "Pass in Integer Files Only!" unless p =~ /\A[+-]?\d+\z/
          end
          break
        end
      end
    end
    
  end
  
  # x = Processor.to_hash_float_block("../../test/data/atmsg_graph_003_003_rur_pred_inmsg.txt",1,3,4,5) do |f1,f2,f3|
  #   f1 * f2 * f3
  # end
  # puts x.inspect
end