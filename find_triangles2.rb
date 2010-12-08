require File.join(File.dirname(__FILE__), 'constants')
require File.join(File.dirname(__FILE__), 'citer_functions')
require File.join(File.dirname(__FILE__), 'ordered_triple')

if __FILE__ == $0
  
  Dir.mkdir(Constants::TR_dir) unless File.directory? Constants::TR_dir
  Dir.mkdir(Constants::TR2_dir) unless File.directory? Constants::TR2_dir
  
  celebrity_file = ARGV.length > 0 ? ARGV[0] : Constants::Celeb_file
  
  File.open(celebrity_file, "r") do |cfile|
    while line = cfile.gets
      a = line.split[0]
      
      puts "Doing Undirected Triangles for #{a}"

      citers_file = Constants::CI_pref + a + Constants::CI_suff
      citers_graph_file = "%s/%s%s_%d%s" % [Constants::CG_dir, Constants::CG_pref, a, Constants::CI_limit, Constants::CG_suff]
      output_file = Constants::TR_dir+"/"+Constants::TR_pref + a + Constants::TR_suff
      output_file2 = Constants::TR2_dir+"/"+Constants::TR_pref + a + Constants::TR2_suff
  
      cf = CiterFunctions.new(Constants::In_file, citers_file, citers_graph_file, Constants::CI_limit)
      cf.build_citer_list
      cf.build_undirected_citer_graph
      citers = cf.citers
      
      #puts citers.inspect
      
      # Count outdegree for each person up to person n
      ofile = File.new(output_file, "w")
      ofile2 = File.new(output_file2, "w")
      file = File.new(citers_file, "r")
      
      running_count = 0
      seen = Hash.new
      triangles = OrderedTriple.new
      steppaths = OrderedTriple.new
      
      while line = file.gets
        curr = line.split(' ')[0].to_i
        
        #puts "curr is #{curr}"
        #puts "seen is #{seen.inspect}"
        
        seen_curr = Hash.new
        if citers[curr]
          citers[curr].each_key do |c| # For each node adjacent to curr
            if seen[c] 
              # When curr is at the end of a 2 step path
              if citers[c]
                citers[c].each_key do |k| # For each node adjacent to each node adjacent to curr
                  if seen[k] && k != curr
                    if citers[k][curr] # There is a triangle
                      triangles.add(curr,c,k)
                      steppaths.add13Same(c,k,curr)
                      steppaths.add13Same(k,curr,c)
                    end
                    #puts "adding #{curr} #{c} #{k}"
                    steppaths.add13Same(curr,c,k) # There is a 3 step path
                  end
                end
              end

              # When curr is in the middle of a 2 step path
              seen_curr.each_key do |ck|
                steppaths.add13Same(c,curr,ck)
              end
              seen_curr[c] = true

            end
          end
        end

        seen[curr] = true
        running_count += 1

        steppaths.resetHash
        
        # Print to file
        ofile.puts "%d %d" % [running_count, triangles.count]
        ofile2.puts "%d %d %d" % [running_count, triangles.count, steppaths.count]
        
        print running_count.to_s + "\t"
        
        if running_count >= Constants::CI_limit
          break
        end
      end
      
      file.close
      ofile.close
      ofile2.close
      print "\n\n"
      
    end
  end
end