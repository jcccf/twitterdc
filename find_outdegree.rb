require File.join(File.dirname(__FILE__), 'constants')

if __FILE__ == $0
  
  Dir.mkdir(Constants::OU_dir) unless File.directory? Constants::OU_dir
  
  celebrity_file = ARGV.length > 0 ? ARGV[0] : Constants::Celeb_file
  
  File.open(celebrity_file, "r") do |cfile|
    while line = cfile.gets
      a = line.split[0]
      
      puts "Doing Outdegree for #{a}"

      citers_file = Constants::CI_pref + a + Constants::CI_suff
      output_file = Constants::OU_dir+"/"+Constants::OU_pref + a + Constants::OU_suff
  
      # Build list of citers
      citers = Hash.new({})
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
        if citer_list[c] != nil && citer_list[d] != nil
          citers[c][d] = parts[3].to_i
        end
      end
      file.close
      
      puts "Built list of people that citers cite"
      #p citers
  
      # Count total outdegree up to person n
      running_count = 0
      od_count = 0
      ofile = File.new(output_file, "w")
      seen = Array.new
      file = File.new(citers_file, "r")
      while line = file.gets
        parts = line.split(' ')
        curr = parts[0].to_i
        time = parts[1].to_i
        found = 0
        seen.each do |s|
          if citers[s][curr] != nil
            od_count += 1
          end
          if citers[curr][s] != nil
            od_count += 1
          end
        end
        seen << curr
        running_count += 1
        ofile.puts "%d %d" % [running_count, od_count]
      end
      file.close
      ofile.close
      print "\n\n"
  
      # # Make outdegree count
      # ofile = File.new(output_file, "w")
      # count = 0
      # File.open(Constants::In_file) do |file|
      #   while line = file.gets
      #      parts = line.split(' ')
      #       c = parts[0].to_i # Src
      #       d = parts[1].to_i # Dst
      #       if citer_list[c] != nil && citer_list[d] != nil
      #         citers[c] += 1
      #       end
      #       count += 1
      #       if count % Constants::OU_print_freq == 0
      #         # Calculate average outdegree
      #         out = citers.inject(0) { |sum,(_,v)| sum + v }
      #         out /= citers.size.to_f
      #         ofile.puts "%d %f" % [count, out]
      #         print "."
      #       end
      #   end
      # end
      # ofile.close
      
    end
  end
end