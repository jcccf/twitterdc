require File.join(File.dirname(__FILE__), 'constants')
require File.join(File.dirname(__FILE__), 'disjoint_set')

if __FILE__ == $0
  
  Dir.mkdir(Constants::UC_dir) unless File.directory? Constants::UC_dir
  
  celebrity_file = (ARGV.length > 0) ? ARGV[0] : Constants::Celeb_file
  
  File.open(celebrity_file, "r") do |cfile|
    while line = cfile.gets
      a = line.split[0]
      
      puts "Doing Undirected Component for #{a}"

      citers_file = Constants::CI_pref + a + Constants::CI_suff
      output_file = Constants::UC_dir+"/"+Constants::CI_pref + a + Constants::UC_suff
  
      # Build list of citers
      citers = Hash.new()
      citer_list = {}
      i = 0
      file = File.new(citers_file, "r")
      while line = file.gets
        parts = line.split(' ')
        citer_list[parts[0].to_i] = parts[1].to_i
        i += 1
        if i >= Constants::CI_limit
          break
        end
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
          citers[c] ||= Hash.new()
          citers[c][d] = true
          citers[d] ||= Hash.new()
          citers[d][c] = true
        end
      end
      file.close
      
      puts "Built list of people that citers cite"
      # puts citers.inspect
  
      # Find out if anyone before that citer cited that person before the person cited the target
      running_count = 0
      citer_set = DisjointSet.new
      ofile = File.new(output_file, "w")
      seen = Array.new
      file = File.new(citers_file, "r")
      while line = file.gets
        parts = line.split(' ')
        curr = parts[0].to_i
        time = parts[1].to_i
        citer_set.add(curr)
        seen.each do |s|
          if citers[s] != nil && citers[s][curr] != nil
            citer_set.union(s,curr)
          end
        end
        seen << curr
        running_count += 1
        ofile.puts "%d %s" % [running_count, citer_set.largestsize]
        
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