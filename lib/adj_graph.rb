require 'set'

class AdjGraph
  def initialize
    @g = {}
    
    # Tarjan variables
    @t_index = 0
    @t_stack = []
    @tg_index = {}
    @tg_lowlink = {}
    @t_result = []
    
    @t_pstack = []
    @t_forindex = Hash.new(0)
    @t_onstack = Hash.new(false)
  end
  
  def assert
    raise "Assertion failed !" unless yield
  end
  
  def add_node(id)
    @g[id] = Set.new
  end
  
  def add_directed_edge(id1,id2)
    @g[id1] ||= Array.new
    @g[id1] << id2
  end
  
  def add_undirected_edge(id1,id2)
    @g[id1] ||= Set.new
    @g[id2] ||= Set.new
    @g[id1] << id2
    @g[id2] << id1
  end
  
  def tarjan
    @t_index = 0
    @t_stack = []
    @tg_index = {}
    @tg_lowlink = {}
    @t_result = []
    
    @t_pstack = []
    @t_forindex = Hash.new(0)
    @t_onstack = Hash.new(false)
    @g.each_key do |k|
      if @tg_index[k] == nil
        tarjan_iter(k)
      end
    end
    @t_result.sort!.reverse!
  end
  
  def tarjan_recursive
    @t_index = 0
    @t_stack = []
    @tg_index = {}
    @tg_lowlink = {}
    @t_result = []

    @g.each_key do |k|
      if @tg_index[k] == nil
        tarjan_helper(k)
      end
    end
    @t_result.sort!.reverse!
  end
  
  def tarjan_string
    tarjan.inject("") {|s,i| s + " " + i.to_s }
  end
  
  def tarjan_string_limit(n)
    tarjan.take(n).inject("") {|s,i| s + " " + i.to_s }
  end
  
  private
  
  def tarjan_helper(v)
    @tg_index[v] = @t_index
    @tg_lowlink[v] = @t_index
    @t_index += 1
    @t_stack.push v
    
    if @g[v] != nil
      @g[v].each do |vp|
        if @tg_index[vp] == nil
          tarjan_helper(vp)
          @tg_lowlink[v] = [@tg_lowlink[v],@tg_lowlink[vp]].min
        elsif @t_stack.include?(vp)
          @tg_lowlink[v] = [@tg_lowlink[v],@tg_index[vp]].min
        end
      end
    end
    
    if @tg_index[v] == @tg_lowlink[v]
      #print "SCC:"
      count = 0
      begin
        vq = @t_stack.pop
        #print vq
        count += 1
      end while vq != v
      
      @t_result << count
    end
  end
  
  def tarjan_iter(v)
    @t_pstack.push v
    
    while @t_pstack.size > 0
      v = @t_pstack.last
      
      #puts "v is %d" % v
      
      # Same as first part of tarjan_helper
      if @tg_index[v] == nil
        @tg_index[v] = @t_index
        @tg_lowlink[v] = @t_index
        @t_index += 1
        @t_stack.push v
      end
      
      if @g[v] != nil
        
        if @t_onstack[v]
          vp = @g[v][@t_forindex[v]]
          assert{@tg_index[vp] != nil}
          @t_onstack.delete(v)
          @tg_lowlink[v] = [@tg_lowlink[v],@tg_lowlink[vp]].min
          @t_forindex[v] += 1
        end
        
        while @t_forindex[v] < @g[v].size
          vp = @g[v][@t_forindex[v]]
          #puts "looking at vp %d" % vp

          if @tg_index[vp] == nil
            @t_onstack[v] = true # Means that v is waiting for a recursive reply
            @t_pstack.push vp
            break
          end
          
          if @t_stack.include?(vp)
            @tg_lowlink[v] = [@tg_lowlink[v],@tg_index[vp]].min
          end
          
          @t_forindex[v] += 1
        end
        
        if @t_forindex[v] == @g[v].size
          @t_pstack.pop
          tarjan_iter_end(v)
        end
      else
        @t_pstack.pop
        tarjan_iter_end(v)
      end
    end
  end
  
  def tarjan_iter_end(v)
    if @tg_index[v] == @tg_lowlink[v]
      #print "SCC:"
      count = 0
      begin
        vq = @t_stack.pop
        #print vq
        count += 1
      end while vq != v

      @t_result << count
    end
  end
  
end

a = AdjGraph.new
a.add_directed_edge(1,2)
a.add_directed_edge(2,3)
a.add_directed_edge(3,1)
a.add_directed_edge(4,1)
a.add_directed_edge(4,5)
a.add_directed_edge(5,4)
a.add_directed_edge(1,5)
a.add_directed_edge(1,6)
puts a.tarjan_string_limit(1000)