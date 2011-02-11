require File.join(File.dirname(__FILE__), 'constants')
require File.join(File.dirname(__FILE__), 'citer_functions')

class FindDirectedClosure
  def initialize(citers)
    @citers = citers
    @running_count = 0
    @dc_count = 0
    @seen = Array.new
  end
  
  def iterate(curr,time)
    found = 0
    if @citers[curr]
      @seen.each do |s|
        if @citers[curr][s] && @citers[curr][s] < time
          found += 1
        end
      end
      if found > 0
        print "."
        @dc_count += 1
      end
    end
    @seen << curr
    @running_count += 1
    
    return @running_count, @dc_count
  end
end

if __FILE__ == $0
  
  Dir.mkdir(Constants::DC_dir) unless File.directory? Constants::DC_dir
  
  celebrity_file = (ARGV.length > 0) ? ARGV[0] : Constants::Celeb_file
  
  File.open(celebrity_file, "r") do |cfile|
    while line = cfile.gets
      a = line.split[0]
      
      puts "Doing DC for #{a}"

      citers_file = Constants::CI_pref + a + Constants::CI_suff
      citers_graph_file = "%s/%s%s_%d%s" % [Constants::CG_dir, Constants::CG_pref, a, Constants::CI_limit, Constants::CG_suff]
      output_file = Constants::DC_dir+"/"+Constants::DC_pref + a + Constants::DC_suff
  
      cf = CiterFunctions.new(Constants::In_file, citers_file, citers_graph_file, Constants::CI_limit)
      cf.build_citer_list
      cf.build_directed_citer_graph_time
      citers = cf.citers
      
      #puts citers.inspect
      
      # Find out if anyone before that citer cited that person before the person cited the target
      
      dc = FindDirectedClosure.new(citers)
      
      File.open(output_file+"~","w") do |ofile|
        File.open(citers_file) do |file|
          while line = file.gets
            parts = line.split
            rc, dt = dc.iterate(parts[0].to_i,parts[1].to_i)
            ofile.puts "%d %d" % [rc, dt]
          end
        end
      end
      
      File.rename(output_file+"~",output_file)
      print "\n\n"
    end
  end
end