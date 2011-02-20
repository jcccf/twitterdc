require 'gnuplot'

module ForestLib
  
  # Abstraction to plot graphs using gnuplot
  class Plotter
    
    # Regular plot function
    def self.plot(title,xlabel,ylabel,xp,yp,output_file)
      Gnuplot.open do |gp|
        Gnuplot::Plot.new( gp ) do |plot|

          plot.term 'pngcairo size 600,300'

          plot.title title
          plot.xlabel xlabel
          plot.ylabel ylabel

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