require File.join(File.dirname(__FILE__), 'constants')
require File.join(File.dirname(__FILE__), 'citer_functions')
require File.join(File.dirname(__FILE__), 'adj_graph')

class FindStronglyConnected
  def initialize(citers)
    @citers = citers
    @running_count = 0
    @citer_graph = AdjGraph.new
    @seen = Hash.new
  end
  
  def iterate(curr)
    @seen[curr] = true
    
    @seen.each_key do |k|
      if @citers[curr] && @citers[curr][k]
        @citer_graph.add_directed_edge(curr,k)
        #puts "adding #{curr} #{k}"
        @citers[curr].delete k
      end
      if @citers[k] && @citers[k][curr]
        @citer_graph.add_directed_edge(k,curr)
        #puts "adding #{k} #{curr}"
        @citers[k].delete curr
      end
    end
    
    @running_count += 1
    
    return @running_count, @citer_graph.tarjan_string_limit(100)
  end
end

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
      
      #puts citers.inspect
      
      # Add people to the graph and calculate the strongly connected component each time
      sc = FindStronglyConnected.new(citers)
      File.open(output_file+"~","w") do |ofile|
        File.open(citers_file, "r") do |file|      
          while line = file.gets
            curr = line.split[0].to_i
            
            rc, ta = sc.iterate(curr)
            
            ofile.puts "%d %s" % [rc, ta]
            print "."
            if rc >= Constants::CI_limit
              break
            end
          end
        end
      end
      File.rename(output_file+"~",output_file)
      print "\n\n"
    end
  end
end