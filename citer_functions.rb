class CiterFunctions
  attr_accessor :citers, :citer_list
  
  def initialize(in_file, citers_file, citers_graph_file, limit)
    @in_file = in_file
    @citers_file = citers_file
    @citers_graph_file = citers_graph_file
    
    @limit = limit
    
    @citers = Hash.new
    @citer_list = {}
  end
  
  def build_citer_list
    print "Building citer list in memory..."
    @citer_list = {}
    count = 0
    File.open(@citers_file) do |file|
      while line = file.gets
        parts = line.split
        @citer_list[parts[0].to_i] = parts[1].to_i
        
        count += 1
        if count >= @limit
          break
        end
      end
    end
    print "done\n"
  end
  
  def build_directed_citer_graph_block
    if @citer_list.size == 0
      build_citer_list
    end
    
    print "Building directed citer graph in memory..."
    if File.exist?(@citers_graph_file)
      print "Using graph file..."
      File.open(@citers_graph_file) do |file|
        while line = file.gets
          parts = line.split
          c = parts[0].to_i
          d = parts[1].to_i
          if citer_list[c] != nil && citer_list[d] != nil
            yield(c,d)
          end
        end
      end
    else
      print "Graph file doesn't exist, using input file..."
      File.open(@in_file) do |file|
        while line = file.gets
          parts = line.split
          c = parts[0].to_i
          d = parts[1].to_i
          if citer_list[c] != nil && citer_list[d] != nil
            yield(c,d)
          end
        end
      end
    end
    print "done\n"    
  end
  
  def build_directed_citer_graph
    if @citer_list.size == 0
      build_citer_list
    end
    @citers = Hash.new()
    
    print "Building directed citer graph in memory..."
    if File.exist?(@citers_graph_file)
      print "Using graph file..."
      File.open(@citers_graph_file) do |file|
        while line = file.gets
          parts = line.split
          c = parts[0].to_i
          d = parts[1].to_i
          if citer_list[c] != nil && citer_list[d] != nil
            citers[c] ||= Hash.new()
            citers[c][d] = true
          end
        end
      end
    else
      print "Graph file doesn't exist, using input file..."
      File.open(@in_file) do |file|
        while line = file.gets
          parts = line.split
          c = parts[0].to_i
          d = parts[1].to_i
          if citer_list[c] != nil && citer_list[d] != nil
            citers[c] ||= Hash.new()
            citers[c][d] = true
          end
        end
      end
    end
    print "done\n"
  end
  
  def build_directed_citer_graph_time
    if @citer_list.size == 0
      build_citer_list
    end
    @citers = Hash.new()
    
    print "Building directed citer graph in memory..."
    if File.exist?(@citers_graph_file)
      print "Using graph file..."
      File.open(@citers_graph_file) do |file|
        while line = file.gets
          parts = line.split
          c = parts[0].to_i
          d = parts[1].to_i
          t = parts[2].to_i
          if citer_list[c] != nil && citer_list[d] != nil
            citers[c] ||= Hash.new()
            citers[c][d] = t
          end
        end
      end
    else
      print "Graph file doesn't exist, using input file..."
      File.open(@in_file) do |file|
        while line = file.gets
          parts = line.split
          c = parts[0].to_i
          d = parts[1].to_i
          t = parts[2].to_i
          if citer_list[c] != nil && citer_list[d] != nil
            citers[c] ||= Hash.new()
            citers[c][d] = t
          end
        end
      end
    end
    print "done\n"
  end
  
  def build_undirected_citer_graph
    if @citer_list.size == 0
      build_citer_list
    end
    @citers = Hash.new()
    
    puts "Building undirected citer graph in memory..."
    if File.exist?(@citers_graph_file)
      puts "Using graph file"
      File.open(@citers_graph_file) do |file|
        while line = file.gets
          parts = line.split
          c = parts[0].to_i
          d = parts[1].to_i
          if citer_list[c] != nil && citer_list[d] != nil
            citers[c] ||= Hash.new
            citers[d] ||= Hash.new
            citers[c][d] = true
            citers[d][c] = true
          end
        end
      end
    else
      puts "Graph file doesn't exist, using input file"
      File.open(@in_file) do |file|
        while line = file.gets
          parts = line.split
          c = parts[0].to_i
          d = parts[1].to_i
          if citer_list[c] != nil && citer_list[d] != nil
            citers[c] ||= Hash.new
            citers[d] ||= Hash.new
            citers[c][d] = true
            citers[d][c] = true
          end
        end
      end
    end
  end
  
end