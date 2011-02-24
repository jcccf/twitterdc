require 'gnuplot'

module ForestLib
  
  # Abstraction to plot graphs using gnuplot
  class Plotter
    
    # Regular plot function
    def self.plot(title,xlabel,ylabel,xp,yp,output_file,plot_type="lines")
      Gnuplot.open do |gp|
        Gnuplot::Plot.new( gp ) do |plot|

          plot.term 'pngcairo size 600,300'

          plot.title title
          plot.xlabel xlabel
          plot.ylabel ylabel

          #x = (0..50).collect { |v| v.to_f }
          #y = x.collect { |v| v ** 2 }

          plot.data << Gnuplot::DataSet.new( [xp, yp] ) do |ds|
            ds.with = plot_type #lines,linespoints
            ds.notitle
          end

          plot.output output_file
        end
      end  
    end
    
    # Plot N sets of data on the same axis. xpN and ypN are arrays of arrays of points.
    # I.e. xpN[i] and ypn[i] correspond to one set of data points
    def self.plotN(title,xlabel,ylabel,titles,xpN,ypN,output_file)
      Gnuplot.open do |gp|
        Gnuplot::Plot.new( gp ) do |plot|

          plot.term 'pngcairo size 600,600'
          #plot.yrange '[0:10]'

          plot.title title
          plot.xlabel xlabel
          plot.ylabel ylabel
          #plot.set "multiplot layout 15,1 title=\"test title\""

          #x = (0..50).collect { |v| v.to_f }
          #y = x.collect { |v| v ** 2 }
          
          plot.data = []

          xpN.each_with_index do |xp,i|
            plot.data << Gnuplot::DataSet.new( [xp, ypN[i]] ) do |ds|
              ds.with = "lines" #linespoints
              ds.title = titles[i]
            end
          end

          plot.output output_file
        end
      end  
    end
    
  end
  
end