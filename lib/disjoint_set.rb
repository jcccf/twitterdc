class DisjointSet
  def initialize
    @h = {}
    @r = {}
  end
  
  def add(id)
    @h[id] = id
    @r[id] = 0
  end
  
  def union(id1,id2)
    id1 = parent(id1)
    id2 = parent(id2)
    if @r[id1] < @r[id2]
      @h[id1] = @h[id2]
    else
      @h[id2] = @h[id1]
      if @r[id1] == @r[id2]
        @r[id1] += 1
      end
    end
  end
  
  def parent(id)
    if id != @h[id]
      @h[id] = parent(@h[id])
    else
      id
    end
  end
  
  def optimize
    @h.each { |k,_| parent(k) }
  end
  
  def largestsize
    self.optimize
    sizes = Hash.new(0)
    @h.each { |_,v| sizes[v] += 1 }
    result = sizes.sort{ |a,b| a[1] <=> b[1] }.reverse
    s = ""
    result.each { |_,v| s += v.to_s + " " }
    s
  end
  
  def inspect
    @h.inspect
  end
end

# ds = DisjointSet.new
# ds.add(1)
# ds.add(2)
# ds.add(3)
# ds.add(4)
# ds.union(2,3)
# ds.union(1,4)
# ds.union(3,4)
# puts ds.inspect
# puts ds.largestsize