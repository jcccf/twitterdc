require File.join(File.dirname(__FILE__), 'constants')

if __FILE__ == $0
  
  Dir.mkdir(Constants::OUM_dir) unless File.directory? Constants::OUM_dir
  
  celebrity_file = ARGV.length > 0 ? ARGV[0] : Constants::Celeb_file
  
  File.open(celebrity_file, "r") do |cfile|
    while line = cfile.gets
      a = line.split[0]
      
      puts "Doing Median Outdegree for #{a}"

      citers_file = Constants::CI_pref + a + Constants::CI_suff
      output_file = Constants::OUM_dir+"/"+Constants::OU_pref + a + Constants::OUM_suff
  
      # Build list of citers
      citers = Hash.new({})
      citer_list = {}
      i = 0
      File.open(citers_file) do |file|
        while line = file.gets
          parts = line.split(' ')
          citer_list[parts[0].to_i] = parts[1].to_i
          i += 1
          if i >= Constants::CI_limit
            break
          end
        end
      end
      
      puts "Built list of citers"
      #p citer_list
  
      # Build lists of people that citers cite
      File.open(Constants::In_file) do |file|
        while line = file.gets
          parts = line.split(' ')
          c = parts[0].to_i
          d = parts[1].to_i
          if citer_list[c] != nil && citer_list[d] != nil
            citers[c][d] = parts[3].to_i
          end
        end
      end
      
      puts "Built list of people that citers cite"
      #p citers
  
      # Count outdegree for each person up to person n
      running_count = 0
      od_hash = Hash.new(0)
      ofile = File.new(output_file, "w")
      seen = Array.new
      file = File.new(citers_file, "r")
      while line = file.gets
        parts = line.split(' ')
        curr = parts[0].to_i
        time = parts[1].to_i
        found = 0
        od_hash[curr] = 0
        seen.each do |s|
          if citers[s][curr] != nil
            od_hash[s] += 1
          end
          if citers[curr][s] != nil
            od_hash[curr] += 1
          end
        end
        seen << curr
        running_count += 1
        
        # Find median
        out = od_hash.sort { |a,b| a[1]<=>b[1] }
        out_len = out.length
        med = (out_len % 2 == 0) ? (out[out_len/2][1]+out[out_len/2-1][1])/2.0 : out[out_len/2][1]
        
        ofile.puts "%d %d" % [running_count, med]
        
        if running_count >= Constants::CI_limit
          break
        end
      end
      file.close
      ofile.close
      print "\n\n"
      
    end
  end
end

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
#       if count % Constants::OU_print_freq == 0 && citers.length > 0
#         # Calculate median outdegree
#         out = citers.sort { |a,b| a[1] <=> b[1] }
#         out_len = out.length
#         med = (out_len % 2 == 0) ? (out[out_len/2][1]+out[out_len/2-1][1])/2.0 : out[out_len/2][1]
#         ofile.puts "%d %f" % [count, med]
#         print "."
#       end
#   end
# end
# ofile.close