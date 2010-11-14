require 'rubygems'
require 'gnuplot'
require 'constants'

if __FILE__ == $0
  
  celebrity_file = ARGV.length > 0 ? ARGV[0] : Constants::Celeb_file
  
  File.open(celebrity_file, "r") do |cfile|
    while line = cfile.gets
      a = line.split[0]
      dc_file = Constants::DC_dir+"/"+Constants::DC_pref + a + Constants::DC_suff
      output_file = Constants::DC_dir+"/"+Constants::DC_pref + a + Constants::IM_suff
      puts "Building graph for %s" % a
      
      # Build X and Y coordinates
      x, y = Array.new, Array.new
      File.open(dc_file, "r") do |dcfile|
        count = 0
        while dline = dcfile.gets
          xco, yco = dline.split
          #if count < 8000
            x << xco
            y << yco
          #end
          count += 1
        end
      end
      
      # Build Graph
      Gnuplot.open do |gp|
        Gnuplot::Plot.new( gp ) do |plot|
          
          plot.term 'pngcairo size 600,300'

          plot.title  "Directed Closure for %s" % a
          plot.xlabel "Number of @s"
          plot.ylabel "Number of Directed Closures"

          #x = (0..50).collect { |v| v.to_f }
          #y = x.collect { |v| v ** 2 }

          plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
            ds.with = "linespoints"
            ds.notitle
          end
          
          plot.output output_file
        end
      end
      
    end
  end
end