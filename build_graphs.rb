require 'rubygems'
require 'gnuplot'
require 'constants'

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

if __FILE__ == $0
  buildPlots(Constants::DC_dir,"Directed Closure", "Number of @s", "Directed Closures Ratio") do |x,y|
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
    [xp, yp]
  end
  
  buildPlots(Constants::OU_dir,"Mean Outdegree", "Number of fans", "Mean Outdegree") do |x,y|
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
    [xp, yp]
  end
  
  buildPlots(Constants::OUM_dir,"Median Outdegree", "Number of fans", "Median Outdegree") do |x,y|
    xp, yp = Array.new, Array.new
    cu = 0
    x.each_with_index do |xv,i|
      cu += y[i]
      if i >= 100
        xp << i - 50
        yp << (cu / 100.0)
        cu -= y[i-100]
      end
    end
    [xp, yp]
  end
  
  buildPlots(Constants::UC_dir,"Undirected Component", "Number of fans", "Proportion in Component") do |x,y|
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
    [xp, yp]
  end
  
  buildPlots(Constants::TR_dir,"Undirected Triangles", "Number of fans (n)", "Undirected Triangles/n") do |x,y|
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
    [xp, yp]
  end
  
  buildPlotsZ(Constants::TR2_dir,"Undirected Triangles and 2 Step Paths", "Number of fans (n)", "Undirected Triangles/2 step paths") do |x,y,z|
    xp, yp = Array.new, Array.new
    cu = 0
    cu2 = 0
    x.each_with_index do |xv,i|
      cu += y[i]
      cu2 += z[i]
      if i >= 100
        xp << i - 50
        yp << (cu / 100.0) / (cu2 / 100.0)
        cu -= y[i-100]
        cu2 -= z[i-100]
      end
    end
    [xp, yp]
  end
  
  buildPlots(Constants::SC_dir,"Size of Strongly Connected Component", "Number of fans", "Size of Strongly Connected Component") do |x,y|
    xp, yp = Array.new, Array.new
    cu = 0
    x.each_with_index do |xv,i|
      cu += y[i]
      if i >= 100
        xp << i - 50
        yp << (cu / 100.0)
        cu -= y[i-100]
      end
    end
    [xp, yp]
  end
end