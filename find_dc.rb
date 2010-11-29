require File.join(File.dirname(__FILE__), 'constants')

if __FILE__ == $0
  
  Dir.mkdir(Constants::DC_dir) unless File.directory? Constants::DC_dir
  
  celebrity_file = ARGV[0] if ARGV.length > 0
  
  File.open(Constants::Celeb_file, "r") do |cfile|
    while line = cfile.gets
      a = line.split[0]
      
      puts "Doing DC for #{a}"

      citers_file = Constants::CI_pref + a + Constants::CI_suff
      output_file = Constants::DC_dir+"/"+Constants::DC_pref + a + Constants::DC_suff
  
      # Build list of citers
      citers = Hash.new()
      citer_list = {}
      file = File.new(citers_file, "r")
      while line = file.gets
        parts = line.split(' ')
        citer_list[parts[0].to_i] = parts[1].to_i
      end
      file.close
      
      puts "Built list of citers"
      #p citer_list
  
      # Build lists of people that citers cite
      file = File.new(Constants::In_file)
      while line = file.gets
        parts = line.split(' ')
        c = parts[0].to_i
        d = parts[1].to_i
        if citer_list[c] != nil
          citers[c] ||= Hash.new()
          citers[c][d] = parts[3].to_i
        end
      end
      file.close
      
      puts "Built list of people that citers cite"
      puts citers.inspect
      #p citers
  
      # Find out if anyone before that citer cited that person before the person cited the target
      running_count = 0
      dc_count = 0
      ofile = File.new(output_file, "w")
      seen = Array.new
      file = File.new(citers_file, "r")
      while line = file.gets
        parts = line.split(' ')
        curr = parts[0].to_i
        time = parts[1].to_i
        found = 0
        seen.each do |s|
          if citers[s][curr] != nil && citers[s][curr] < time
            found += 1
          end
        end
        if found > 0
          print "O"
          dc_count += 1
        end
        seen << curr
        running_count += 1
        ofile.puts "%d %d" % [running_count, dc_count]
      end
      file.close
      ofile.close
      print "\n\n"
    end
  end
end