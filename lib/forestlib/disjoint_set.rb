module ForestLib

  # Representation of a disjoint set
  class DisjointSet
    def initialize
      @h = {}
      @r = {}
    end
  
    # Add an item to the set
    def add(id)
      @h[id] ||= id
      @r[id] ||= 0
    end
  
    # Union the set containing id1 and that containing id2
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
  
    # Find the parent of id
    def parent(id)
      if id != @h[id]
        @h[id] = parent(@h[id])
      else
        id
      end
    end
  
    # Optimize the representation by flattening the tree
    def optimize
      @h.each { |k,_| parent(k) }
    end
  
    # Find the largest set
    def largestsize
      self.optimize
      sizes = Hash.new(0)
      @h.each { |_,v| sizes[v] += 1 }
      result = sizes.sort{ |a,b| a[1] <=> b[1] }.reverse
      s = ""
      result.each { |_,v| s += v.to_s + " " }
      s
    end
  
    # Look at the current state of the disjoint set
    def inspect
      @h.inspect
    end
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