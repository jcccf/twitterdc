require 'gnuplot'

module ForestLib
  
  # DataSet which takes in (x,y,z) triples, as a 2D hash with z corresponding to the intensity
  # I.e. hash[x][y] = z
  class HeatMapData
    def initialize(hash)
      @hash = hash
    end
    
    def to_gsplot
      f = ""
      @hash.each do |x,v|
        v.each do |y,z|
          f += "#{x} #{y} #{z}\n"
        end
      end
      f
    end
  end
  
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
    
    # Plot a heat map, with z values corresponding to intensity
    def self.plotHeatMap(title,xlabel,ylabel,heatmap,output_file,plot_type="points pt 7 palette")
      Gnuplot.open do |gp|
        Gnuplot::SPlot.new( gp ) do |plot|
          plot.term 'pngcairo size 600,600'
          
          plot.yrange '[0:60]'
          plot.xrange '[0:60]'

          plot.set "size square"
          plot.title title
          plot.xlabel xlabel
          plot.ylabel ylabel
          plot.set "view map"
          plot.set "palette defined (0 \"white\", 10 \"blue\", 100 \"green\", 1000 \"yellow\", 10000 \"orange\", 100000 \"red\")"

          plot.data << Gnuplot::DataSet.new( heatmap ) do |ds|
            ds.with = plot_type #lines,linespoints
            ds.notitle
          end

          plot.output output_file
        end
      end  
    end
    
  end
  
end