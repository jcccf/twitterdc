require File.join(File.dirname(__FILE__), 'constants')
require File.join(File.dirname(__FILE__), 'adj_graph')

if __FILE__ == $0
  
  Dir.mkdir(Constants::SC_dir) unless File.directory? Constants::SC_dir
  
  celebrity_file = (ARGV.length > 0) ? ARGV[0] : Constants::Celeb_file
  
  File.open(celebrity_file, "r") do |cfile|
    while line = cfile.gets
      a = line.split[0]
      
      puts "Doing Strongly Connected Component for #{a}"

      citers_file = Constants::CI_pref + a + Constants::CI_suff
      output_file = Constants::SC_dir+"/"+Constants::CI_pref + a + Constants::SC_suff
  
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
        end
      end
      file.close
      
      puts "Built list of people that citers cite"
      # puts citers.inspect
  
      # Add people to the graph and calculate the strongly connected component each time
      running_count = 0
      citer_graph = AdjGraph.new
      seen = Hash.new
      ofile = File.new(output_file, "w")
      file = File.new(citers_file, "r")
      while line = file.gets
        parts = line.split(' ')
        curr = parts[0].to_i
        seen[curr] = true

        citers.each_key do |k|
          if seen[k] != nil
            citers[k].each_key do |m|
              if seen[m] != nil
                citer_graph.add_directed_edge(k,m)
                citers[k].delete m
              end
            end
          end
        end
        
        running_count += 1
        ofile.puts "%d %s" % [running_count, citer_graph.tarjan_string_limit(100)]
        print "."
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