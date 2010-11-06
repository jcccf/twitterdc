Input_file = "test2.txt"
Celebrity_file = "celebrities.txt"
Out_prefix = "celeb_"
Out_suffix = ".txt"

class Citer
  attr_accessor :id, :time
  def initialize(id,time)
    @id = id
    @time = time
  end
end

if __FILE__ == $0
  
  # For each celebrity
  cfile = File.new(Celebrity_file,"r")
  while cline = cfile.gets
    cparts = cline.split(' ')
    celeb_id = cparts[0]
    puts "Finding %s" % celeb_id
    
    # Find all citers
    citers = Array.new
    file = File.new(Input_file,"r")
    while line = file.gets
      parts = line.split(' ')
      # puts "%s @ed %s at time %s" % [parts[0], parts[1], parts[3]]
      if parts[1] == celeb_id
        citers << Citer.new(parts[0].to_i,parts[3].to_i)
      end
    end
    file.close
    
    # Sort them and then save
    sfile = File.new(Out_prefix+celeb_id+Out_suffix, "w")
    citers.sort { |a,b| a.time <=> b.time }.each do |citer|
      sfile.puts "%s %s" % [citer.id, citer.time]
    end
    sfile.close
    
  end
  cfile.close
  
end