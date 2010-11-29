require File.join(File.dirname(__FILE__), 'constants')
require File.join(File.dirname(__FILE__), 'adj_graph')

if __FILE__ == $0
  
  Dir.mkdir(Constants::CG_dir) unless File.directory? Constants::CG_dir
  
  celebrity_file = (ARGV.length > 0) ? ARGV[0] : Constants::Celeb_file
  
  File.open(celebrity_file, "r") do |cfile|
    while line = cfile.gets
      a = line.split[0]
      
      puts "Building Citer Graph File for #{a}"

      citers_file = Constants::CI_pref + a + Constants::CI_suff
      output_file = "%s/%s%s_%d%s" % [Constants::CG_dir, Constants::CG_pref, a, Constants::CI_limit, Constants::CG_suff]
      
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
      
      # Build citer graph file
      ofile = File.new(output_file+"~","w")
      File.open(Constants::In_file) do |file|
        while line = file.gets
          parts = line.split
          c = parts[0]
          d = parts[1]
          t = parts[3]
          if citer_list[c.to_i] != nil && citer_list[d.to_i] != nil
            ofile.puts "%s %s %s" % [c,d,t]
          end
        end
      end
      ofile.close
      File.rename(output_file+"~",output_file)
      
      puts "Built graph of citers"

      print "\n\n"
    end
  end
end