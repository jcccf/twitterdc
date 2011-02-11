require File.join(File.dirname(__FILE__), 'constants')

Array_times = 100 # How often to record to the array (every N line reads)
File_times = 1000 # How often to write to the file (every N array writes)

if __FILE__ == $0
  
  Dir.mkdir(Constants::AT_dir) unless File.directory? Constants::AT_dir
  celebrity_file = ARGV.length > 0 ? ARGV[0] : Constants::Celeb_file
  
  at_count = {}
  at_array = {}
  
  File.open(celebrity_file,"r") do |f|
    while line = f.gets
      celeb_id = line.split[0].to_i
      at_count[celeb_id] = 0
      at_array[celeb_id] = Array.new
      puts celeb_id
    end
  end
  
  idx = 0
  file_idx = 0
  File.open(Constants::In_file,"r") do |f|
    while line = f.gets
      ated = line.split[1].to_i
      if(at_count[ated] != nil)
        at_count[ated] += 1
      end
      idx += 1
      
      # Save to array every Array_times lines
      if idx % Array_times == 0
        at_count.each do |k,v|
          at_array[k] << v
        end
      end
      
      # Write to file every File_times * Array_times lines
      if idx % (Array_times*File_times) == 0
        at_count.each do |k,v|
          File.open(Constants::AT_dir+"/"+Constants::AT_pref+k.to_s+Constants::AT_suff,"a") do |af|
            puts "Iteration #{file_idx}"
            j = file_idx
            at_array[k].each do |i|
              af.puts "%d %d" % [j, i]
              j += Array_times
            end
          end
          at_array[k] = Array.new
        end
        file_idx += (Array_times*File_times)
      end
      
    end
  end
  
  # Write to file any outstanding elements in the array
  at_count.each do |k,v|
    File.open(Constants::AT_dir+"/"+Constants::AT_pref+k.to_s+Constants::AT_suff,"a") do |af|
      puts 'opening!'
      j = file_idx
      at_array[k].each do |i|
        af.puts "%d %d" % [j, i]
        j += Array_times
      end
    end
    at_array[k] = Array.new
  end
  
end