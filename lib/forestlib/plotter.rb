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
  
  # DataSet which takes in (x,y,z,a) 4-tuples, as a 3D hash with a corresponding to the intensity
  # I.e. hash[x][y][z] = a
  class HeatMapData3D
    def initialize(hash)
      @hash = hash
    end
    
    def to_gsplot
      f = ""
      @hash.each do |x,v|
        v.each do |y,w|
          w.each do |z,a|
            f += "#{x} #{y} #{z} #{a}\n"
          end
          f += "\n"
        end
        f += "\n"
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
    def self.plotHeatMap(title,xlabel,ylabel,heatmap,output_file,x_range = '[0:60]', y_range='[0:60]', z_range='[0:60]', plot_type="points pt 7 palette")
      Gnuplot.open do |gp|
        Gnuplot::SPlot.new( gp ) do |plot|
          plot.term 'pngcairo size 600,600'
          
          plot.yrange x_range
          plot.xrange y_range
          plot.zrange z_range
          
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
    
    # Plot a 3D heat map, with a values corresponding to intensity
    def self.plotHeatMap3D(title,xlabel,ylabel,heatmap,output_file,x_range = '[0:60]', y_range='[0:60]', plot_type="points pt 7 palette")
      Gnuplot.open do |gp|
        Gnuplot::SPlot.new( gp ) do |plot|
          plot.term 'pngcairo size 800,600'
          
          plot.yrange x_range
          plot.xrange y_range

          plot.title title
          plot.xlabel xlabel
          plot.ylabel ylabel
          plot.set "size square"
          plot.set "view 75,310"
          plot.set "ticslevel 0"
          plot.set "format cb \"%4.1f\""
          plot.set "colorbox user size .03, .6 noborder"
          plot.set "samples 25, 25"
          plot.set "isosamples 50, 50"
          plot.set "palette rgbformulae 33,13,10"
          
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

# h = {}
# h[1] = {}
# h[1][2] = {}
# h[1][2][3] = 4
# h[1][3] = {}
# h[2] = {}
# h[2][3] = {}
# h[2][3][5] = 2
# h[2][3][4] = 4
# h[2][3][3] = 1
# h[2][3][2] = 10000
# 
# heatmap = ForestLib::HeatMapData3D.new(h)
# 
# puts heatmap.to_gsplot
# 
# Gnuplot.open do |gp|
#   Gnuplot::SPlot.new( gp ) do |plot|
#     plot.term 'pngcairo size 800,600'
#     
#     plot.yrange "[0:5]"
#     plot.xrange "[0:5]"
#     #plot.zrange "[0:5]"
# 
#     plot.title "title"
#     plot.xlabel "xlabel"
#     plot.ylabel "ylabel"
#     plot.set "size square"
#     plot.set "view 75,310"
#     plot.set "ticslevel 0"
#     plot.set "format cb \"%4.1f\""
#     plot.set "colorbox user size .03, .6 noborder"
#     plot.set "samples 25, 25"
#     plot.set "isosamples 50, 50"
#     
#     #plot.set "view map"
#     #plot.set "palette defined (0 \"white\", 10 \"blue\", 100 \"green\", 1000 \"yellow\", 10000 \"orange\", 100000 \"red\")"
#     plot.set "palette rgbformulae 33,13,10"
#     
#     #plot.set "pm3d explicit"
#     
#     plot.data << Gnuplot::DataSet.new( heatmap ) do |ds|
#       ds.with = "points pt 7 palette" #lines,linespoints
#       ds.notitle
#     end
# 
#     plot.output "test.png"
#   end
# end