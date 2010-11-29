require File.join(File.dirname(__FILE__), 'constants')
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
      output_file = Constants::TR_dir+"/"+Constants::TR_pref + a + Constants::TR_suff
      output_file2 = Constants::TR2_dir+"/"+Constants::TR_pref + a + Constants::TR2_suff
  
      # Build list of citers
      citers = {}
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
  
      # Build undirected graph of people that cite each other
      File.open(Constants::In_file) do |file|
        while line = file.gets
          parts = line.split(' ')
          c = parts[0].to_i
          d = parts[1].to_i
          if citer_list[c] != nil && citer_list[d] != nil
            citers[c] ||= {}
            citers[c][d] = true
            citers[d] ||= {}
            citers[d][c] = true
          end
        end
      end
      
      puts "Built undirected graph of people that cite each other"
  
      # Count outdegree for each person up to person n
      ofile = File.new(output_file, "w")
      ofile2 = File.new(output_file2, "w")
      file = File.new(citers_file, "r")
      
      running_count = 0
      seen = Array.new
      triangles = OrderedTriple.new
      steppaths = OrderedTriple.new
      
      while line = file.gets
        curr = line.split(' ')[0].to_i
        
        # Find any triangles or 2 step paths containing curr
        seen.each do |s|
          if citers[curr] != nil && citers[curr][s] != nil
            citers[curr].each do |k,_|
              if k != s
                if citers[k] != nil && citers[k][s] != nil
                  triangles.add(curr,s,k)
                end
                steppaths.add(curr,s,k)
              end
            end
          end
        end
        seen << curr
        running_count += 1
        
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