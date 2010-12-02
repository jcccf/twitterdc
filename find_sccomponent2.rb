require File.join(File.dirname(__FILE__), 'constants')
require File.join(File.dirname(__FILE__), 'citer_functions')
require File.join(File.dirname(__FILE__), 'adj_graph')

if __FILE__ == $0
  
  Dir.mkdir(Constants::SC_dir) unless File.directory? Constants::SC_dir
  
  celebrity_file = (ARGV.length > 0) ? ARGV[0] : Constants::Celeb_file
  
  File.open(celebrity_file, "r") do |cfile|
    while line = cfile.gets
      a = line.split[0]
      
      puts "Doing Strongly Connected Component for #{a}"

      citers_file = Constants::CI_pref + a + Constants::CI_suff
      citers_graph_file = "%s/%s%s_%d%s" % [Constants::CG_dir, Constants::CG_pref, a, Constants::CI_limit, Constants::CG_suff]
      output_file = Constants::SC_dir+"/"+Constants::CI_pref + a + Constants::SC_suff
      
      cf = CiterFunctions.new(Constants::In_file, citers_file, citers_graph_file, Constants::CI_limit)
      cf.build_citer_list
      cf.build_directed_citer_graph
      citers = cf.citers
      
      # Add people to the graph and calculate the strongly connected component each time
      running_count = 0
      citer_graph = AdjGraph.new
      seen = Hash.new
      ofile = File.new(output_file+"~", "w")
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
      File.rename(output_file+"~",output_file)
      print "\n\n"
    end
  end
end