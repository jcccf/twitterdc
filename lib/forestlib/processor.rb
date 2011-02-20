module ForestLib
  # Converts files into hashes and so on.
  # Only handles integers
  class Processor
    
    # Converts "a b" on each line of a file into "a => b" mappings
    def self.to_hash(input_file)
      self.validate(input_file)
      h = {}
      File.open(input_file,"r").each do |l|
        parts = l.split(" ", 3)
        h[parts[0].to_i] = parts[1].to_i
      end
      h
    end
    
    # Converts "a b" on each line of a file into "a => b" mappings, but cast b as a float
    def self.to_hash_float(input_file)
      self.validate(input_file)
      h = {}
      File.open(input_file,"r").each do |l|
        parts = l.split(" ", 3)
        h[parts[0].to_i] = parts[1].to_f
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