class OrderedTriple
  # attr_accessor :id, :time
  def initialize
    @h = {}
    @count = 0
  end
  
  def add(e1,e2,e3)
    s = [e1,e2,e3].sort
    @h[s[0]] ||= {}
    @h[s[0]][s[1]] ||= {}
    if !@h[s[0]][s[1]][s[2]]
      @h[s[0]][s[1]][s[2]] = true
      @count += 1
    end
  end
  
  def add13Same(e1,e2,e3)
    s0, s3 = [e1,e3].sort
    @h[s0] ||= {}
    @h[s0][e2] ||= {}
    if !@h[s0][e2][s3]
      @h[s0][e2][s3] = true
      @count += 1
    end
  end
  
  def resetHash
    @h = {}
  end
  
  def count
    @count
  end
  
  def inspect
    @h.inspect
  end
end

# ot = OrderedTriple.new
# ot.add(1,2,3)
# ot.add(2,1,3)
# ot.add(3,1,2)
# ot.add(2,3,4)
# ot.add(4,3,2)
# puts ot.count