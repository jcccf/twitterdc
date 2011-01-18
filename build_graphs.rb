require 'rubygems'
require 'gnuplot'
require 'constants'

$VERBOSE = true

def doPlot(title,xlabel,ylabel,xp,yp,output_file)
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

# Plots 2 datasets on the same graph
def doPlot2(title,xlabel,ylabel,xp,yp,xp2,yp2,output_file)
  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|
      
      plot.term 'pngcairo size 600,600'
      plot.yrange '[0:10]'

      plot.title title
      plot.xlabel xlabel
      plot.ylabel ylabel
      plot.set "multiplot layout 15,1 title=\"test title\""

      #x = (0..50).collect { |v| v.to_f }
      #y = x.collect { |v| v ** 2 }

      plot.data = [
        Gnuplot::DataSet.new( [xp, yp] ) do |ds|
          ds.with = "lines" #linespoints
          ds.notitle
        end,
        Gnuplot::DataSet.new( [xp2, yp2] ) do |ds|
          ds.with = "lines" #linespoints
          ds.notitle
        end
      ]
      
      plot.output output_file
    end
  end  
end

# Plots 2 datasets separately using multiplot
def doPlot2Multi(title,xlabel,ylabel,ylabel2,xp,yp,xp2,yp2,output_file)
  d1 = Gnuplot::DataSet.new( [xp, yp] ) do |ds|
    ds.with = "lines" #linespoints
    ds.notitle
  end
  d2 = Gnuplot::DataSet.new( [xp2, yp2] ) do |ds|
    ds.with = "lines" #linespoints
    ds.notitle
  end
  
  #Use Multiplot by calling Plot.new twice
  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|
      plot.term 'pngcairo size 600,600'
      plot.output output_file
      plot.lmargin '10'
      plot.rmargin '2'
      
      plot.multiplot
      plot.title ''
      plot.xlabel xlabel
      plot.ylabel ylabel
      plot.size '1,0.4' # Always set size before origin
      plot.origin '0.0,0.0'
      plot.bmargin '3'
      plot.tmargin '0'
      plot.data << d1
    end
    Gnuplot::Plot.new(gp) do |plot|
      plot.size '1,0.6'
      plot.origin '0.0,0.4'
      plot.title title
      plot.bmargin '0'
      plot.tmargin '1'
      plot.xlabel ''
      plot.ylabel ylabel2
      plot.data << d2
    end
  end  
end

def getXY(input_file)
  x, y = Array.new, Array.new
  File.open(input_file, "r") do |dcfile|
    count = 0
    while dline = dcfile.gets
      xco, yco = dline.split
      if count < Constants::CI_limit
        x << xco.to_f
        y << yco.to_f
      end
      count += 1
    end
  end
  [x,y]  
end

def getXYZ(input_file)
  x, y, z = Array.new, Array.new, Array.new
  File.open(input_file, "r") do |dcfile|
    count = 0
    while dline = dcfile.gets
      xco, yco, zco = dline.split
      if count < Constants::CI_limit
        x << xco.to_f
        y << yco.to_f
        z << zco.to_f
      end
      count += 1
    end
  end
  [x,y,z]  
end

def getFirstN(input_file,n=2)
  a = Array.new
  n.times {|i| a[i] = Array.new}
  File.open(input_file, "r") do |dcfile|
    count = 0
    while dline = dcfile.gets
      s = dline.split
      if count < Constants::CI_limit
        n.times do |i| 
          a[i] << s[i].to_f if a[i] != nil
        end
      end
      count += 1
    end
  end
  a
end

def buildPlots(prop_dir, name, xlabel, ylabel)
  input_dir = Constants::Graph_basedir+"/"+prop_dir
  output_dir = Constants::Graph_basedir+"/"+prop_dir+"_img"
  
  puts "Invalid input directory" unless File.directory? input_dir
  Dir.mkdir(output_dir) unless File.directory? output_dir
  Dir.chdir(input_dir)
  Dir.glob('*') do |fname|
    input_file = input_dir+"/"+fname
    output_file = output_dir+'/'+fname.split('.')[0] + Constants::IM_suff
    puts "Building %s graph for %s" % [name, input_file]
    
    # Build X and Y coordinates
    x, y = getXY(input_file)
    
    # Building Sliding X and Y
    xp, yp = yield(x,y)
    
    doPlot("%s for %s" % [name, fname.split('.')[0]], xlabel, ylabel, xp, yp, output_file)
  end  
end

def buildPlotsZ(prop_dir, name, xlabel, ylabel)
  input_dir = Constants::Graph_basedir+"/"+prop_dir
  output_dir = Constants::Graph_basedir+"/"+prop_dir+"_img"
  
  puts "Invalid input directory" unless File.directory? input_dir
  Dir.mkdir(output_dir) unless File.directory? output_dir
  Dir.chdir(input_dir)
  Dir.glob('*') do |fname|
    input_file = input_dir+"/"+fname
    output_file = output_dir+'/'+fname.split('.')[0] + Constants::IM_suff
    puts "Building %s graph for %s" % [name, input_file]
    
    # Build X and Y coordinates
    x, y, z = getXYZ(input_file)
    
    # Building Sliding X and Y
    xp, yp = yield(x,y,z)
    
    doPlot("%s for %s" % [name, fname.split('.')[0]], xlabel, ylabel, xp, yp, output_file)
  end  
end

def build2Plots(prop1_dir, prop2_dir, name, xlabel, ylabel)
  input1_dir = Constants::Graph_basedir+"/"+prop1_dir
  input2_dir = Constants::Graph_basedir+"/"+prop2_dir
  output_dir = Constants::Graph_basedir+"/"+prop1_dir+"special_img"
  
  xp, yp, xp2, yp2 = Array.new, Array.new, Array.new, Array.new
  
  puts "Invalid input directory" unless (File.directory? input1_dir) && (File.directory? input2_dir)
  Dir.mkdir(output_dir) unless File.directory? output_dir
  Dir.chdir(input1_dir)
  Dir.glob('*') do |fname|
    # Check for same file in input2 directory
    id = fname.scan(/(\d+)/).flatten[0]
    
    puts "checking"+id
    Dir.chdir(input2_dir)
    next if Dir.glob("*"+id+"*").empty?
    puts "found!"
    
    input1_file = input1_dir+"/"+fname
    input2_file = input2_dir+"/"+Dir.glob("*"+id+"*")[0]
    output_file = output_dir+'/'+fname.split('.')[0] + Constants::IM_suff
    puts "Building %s graph for %s" % [name, input1_file]
    
    # Build X and Y coordinates
    x, y = getXY(input1_file)
    x2, y2 = getXY(input2_file)
    
    # Building Sliding X and Y
    xp, yp, xp2, yp2 = yield(x,y,x2,y2)
    
    doPlot2("%s for %s" % [name, fname.split('.')[0]], xlabel, ylabel, xp, yp, xp2, yp2, output_file)  
  end
end

def build2PlotsSingle(prop_dir, name, xlabel, ylabel, ylabel2)
  input_dir = Constants::Graph_basedir+"/"+prop_dir
  output_dir = Constants::Graph_basedir+"/"+prop_dir+"special_img"
  
  puts "Invalid input directory" unless File.directory? input_dir
  Dir.mkdir(output_dir) unless File.directory? output_dir
  Dir.chdir(input_dir)
  Dir.glob('*') do |fname|
    input_file = input_dir+"/"+fname
    output_file = output_dir+'/'+fname.split('.')[0] + Constants::IM_suff
    puts "Building %s graph for %s" % [name, input_file]
    
    # Build X and Y coordinates
    x, y, z = getXYZ(input_file)
    
    # Building Sliding X and Y
    xp, yp, xp2, yp2 = yield(x,y,z)
    
    doPlot2Multi("%s for %s" % [name, fname.split('.')[0]], xlabel, ylabel, ylabel2, xp, yp, xp2, yp2, output_file)
  end  
end

def build2PlotsUntil(prop_dir, name, xlabel, ylabel, ylabel2)
  input_dir = Constants::Graph_basedir+"/"+prop_dir
  output_dir = Constants::Graph_basedir+"/"+prop_dir+"until_img"
  
  puts "Invalid input directory" unless File.directory? input_dir
  Dir.mkdir(output_dir) unless File.directory? output_dir
  Dir.chdir(input_dir)
  Dir.glob('*') do |fname|
    input_file = input_dir+"/"+fname
    output_file = output_dir+'/'+fname.split('.')[0] + Constants::IM_suff
    puts "Building %s graph for %s" % [name, input_file]
    
    # Build X and Y coordinates
    x, y, *a = getFirstN(input_file, 20)
    z = Array.new
    x.each_with_index do |xval,i|
      cum = 0
      a.each do |aval|
        break unless aval[i] > 3
        cum += aval[i]
      end
      z[i] = xval - cum - y[i]
    end
    
    # Building Sliding X and Y
    xp, yp, xp2, yp2 = yield(x,y,z)
    
    doPlot2Multi("%s for %s" % [name, fname.split('.')[0]], xlabel, ylabel, ylabel2, xp, yp, xp2, yp2, output_file)
  end  
end

if __FILE__ == $0
  
  build2PlotsUntil(Constants::UC_dir, "Undirected Component and People", "Number of fans", "Proportion in Largest", "Number not in Groups > 3") do |x,y,z|
    xp, yp, zp = Array.new, Array.new, Array.new
    cu = 0
    cuz = 0
    x.each_with_index do |xv,i|
      cu += y[i]
      cuz += z[i]
      if i >= 100
        xp << i - 50
        yp << (cu / 100.0) / x[i]
        zp << (cuz / 100.0)
        cu -= y[i-100]
        cuz -= z[i-100]
      end
    end
    [xp, yp, xp, zp] 
  end
  
  # See Sizes of Largest 2 Undirected Components
  # build2PlotsSingle(Constants::UC_dir,"Undirected Component (Largest 2)", "Number of fans", "Proportion in Largest", "Number in 2nd Largest") do |x,y,z|
  #   xp, yp, zp = Array.new, Array.new, Array.new
  #   cu = 0
  #   cuz = 0
  #   x.each_with_index do |xv,i|
  #     cu += y[i]
  #     cuz += z[i]
  #     if i >= 100
  #       xp << i - 50
  #       yp << (cu / 100.0) / x[i]
  #       zp << (cuz / 100.0)
  #       cu -= y[i-100]
  #       cuz -= z[i-100]
  #     end
  #   end
  #   [xp, yp, xp, zp]
  # end
  
  # Overlay Directed Closure and Undirected Component Ratios
  # build2Plots(Constants::DC_dir, Constants::UC_dir, "DC and UC", "Number of fans", "DC Ratio, Prop in Comp") do |x,y,x2,y2|
  #   xp, yp = Array.new, Array.new
  #   cu = 0
  #   x.each_with_index do |xv,i|
  #     cu += y[i]
  #     if i >= 100
  #       xp << i - 50
  #       yp << (cu / 100.0) / x[i]
  #       cu -= y[i-100]
  #     end
  #   end
  #   xp2, yp2 = Array.new, Array.new
  #   cu2 = 0
  #   x.each_with_index do |xv2,i2|
  #     cu2 += y2[i2]
  #     if i2 >= 100
  #       xp2 << i2 - 50
  #       yp2 << (cu2 / 100.0) / x2[i2]
  #       cu2 -= y2[i2-100]
  #     end
  #   end
  #   [xp, yp, xp2, yp2]
  # end
  
  # buildPlots(Constants::DC_dir,"Directed Closure", "Number of @s", "Directed Closures Ratio") do |x,y|
  #   xp, yp = Array.new, Array.new
  #   cu = 0
  #   x.each_with_index do |xv,i|
  #     cu += y[i]
  #     if i >= 100
  #       xp << i - 50
  #       yp << (cu / 100.0) / x[i]
  #       cu -= y[i-100]
  #     end
  #   end
  #   [xp, yp]
  # end
  # 
  # buildPlots(Constants::OU_dir,"Mean Outdegree", "Number of fans", "Mean Outdegree") do |x,y|
  #   xp, yp = Array.new, Array.new
  #   cu = 0
  #   x.each_with_index do |xv,i|
  #     cu += y[i]
  #     if i >= 100
  #       xp << i - 50
  #       yp << (cu / 100.0) / x[i]
  #       cu -= y[i-100]
  #     end
  #   end
  #   [xp, yp]
  # end
  # 
  # buildPlots(Constants::OUM_dir,"Median Outdegree", "Number of fans", "Median Outdegree") do |x,y|
  #   xp, yp = Array.new, Array.new
  #   cu = 0
  #   x.each_with_index do |xv,i|
  #     cu += y[i]
  #     if i >= 100
  #       xp << i - 50
  #       yp << (cu / 100.0)
  #       cu -= y[i-100]
  #     end
  #   end
  #   [xp, yp]
  # end
  # 
  # buildPlots(Constants::UC_dir,"Undirected Component", "Number of fans", "Proportion in Component") do |x,y|
  #   xp, yp = Array.new, Array.new
  #   cu = 0
  #   x.each_with_index do |xv,i|
  #     cu += y[i]
  #     if i >= 100
  #       xp << i - 50
  #       yp << (cu / 100.0) / x[i]
  #       cu -= y[i-100]
  #     end
  #   end
  #   [xp, yp]
  # end
  # 
  # buildPlots(Constants::TR_dir,"Undirected Triangles", "Number of fans (n)", "Undirected Triangles/n") do |x,y|
  #   xp, yp = Array.new, Array.new
  #   cu = 0
  #   x.each_with_index do |xv,i|
  #     cu += y[i]
  #     if i >= 100
  #       xp << i - 50
  #       yp << (cu / 100.0) / x[i]
  #       cu -= y[i-100]
  #     end
  #   end
  #   [xp, yp]
  # end
  # 
  # buildPlotsZ(Constants::TR2_dir,"Undirected Triangles and 2 Step Paths", "Number of fans (n)", "Undirected Triangles/2 step paths") do |x,y,z|
  #   xp, yp = Array.new, Array.new
  #   cu = 0
  #   cu2 = 0
  #   x.each_with_index do |xv,i|
  #     cu += y[i]
  #     cu2 += z[i]
  #     if i >= 100
  #       xp << i - 50
  #       yp << (cu / 100.0) / (cu2 / 100.0)
  #       cu -= y[i-100]
  #       cu2 -= z[i-100]
  #     end
  #   end
  #   [xp, yp]
  # end
  # 
  # buildPlots(Constants::SC_dir,"Size of Strongly Connected Component", "Number of fans", "Size of Strongly Connected Component") do |x,y|
  #   xp, yp = Array.new, Array.new
  #   cu = 0
  #   x.each_with_index do |xv,i|
  #     cu += y[i]
  #     if i >= 100
  #       xp << i - 50
  #       yp << (cu / 100.0)
  #       cu -= y[i-100]
  #     end
  #   end
  #   [xp, yp]
  # end
end