require 'rubygems'
require 'gnuplot'
require 'constants'

if __FILE__ == $0
  
  Dir.mkdir(Constants::DC_dir+"/img") unless File.directory? Constants::DC_dir+"/img"
  
  celebrity_file = ARGV.length > 0 ? ARGV[0] : Constants::Celeb_file
  
  File.open(celebrity_file, "r") do |cfile|
    while line = cfile.gets
      a = line.split[0]
      dc_file = Constants::DC_dir+"/"+Constants::DC_pref + a + Constants::DC_suff
      #output_file = Constants::DC_dir+"/img/"+Constants::DC_pref + a + Constants::IM_suff
      output_file = Constants::DC_dir+"/img/"+Constants::DC_pref + a + "_i" + Constants::IM_suff
      puts "Building graph for %s" % a
      
      # Build X and Y coordinates
      x, y = Array.new, Array.new
      File.open(dc_file, "r") do |dcfile|
        count = 0
        while dline = dcfile.gets
          xco, yco = dline.split
          if count < 16000
            x << xco.to_f
            y << yco.to_f
            # y << yco.to_f / xco.to_f
          end
          count += 1
        end
      end
      
      # Building Sliding X and Y
      xp, yp = Array.new, Array.new
      cu = 0
      x.each_with_index do |xv,i|
        cu += y[i]
        if i >= 100
          xp << i - 50
          yp << (cu / 100.0) / x[i]
          cu -= y[i-100]
        end
      end
      
      # Build Graph
      Gnuplot.open do |gp|
        Gnuplot::Plot.new( gp ) do |plot|
          
          plot.term 'pngcairo size 600,300'

          plot.title  "Directed Closure for %s" % a
          plot.xlabel "Number of @s"
          plot.ylabel "Directed Closures Ratio"

          #x = (0..50).collect { |v| v.to_f }
          #y = x.collect { |v| v ** 2 }

          plot.data << Gnuplot::DataSet.new( [xp, yp] ) do |ds|
            ds.with = "lines" #linespoints
            ds.notitle
          end
          
          plot.output output_file
        end
      end
      
    end
  end
end