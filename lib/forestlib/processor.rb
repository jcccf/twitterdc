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
end