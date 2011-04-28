module TwitterDc
  class Constant
    def initialize(c, name, extras = [])
      @c = c
      @name = name
      @extras = extras
      @name_extras = extras.empty? ? @name : @name + "_" + extras.join("_")
    end
    
    def filename(k)
      sprintf("%s/%03d_%03d_%s.%s", @c.base, @c.n, k, @name_extras, "txt")
    end
    
    def image_filename(k)
      sprintf("%s/%03d_%03d_%s.%s", @c.base+"/images", @c.n, k, @name_extras, "png")
    end
    
    def pfilename(k)
      sprintf("%s/%03d_%03d_%s_pct.%s", @c.base, @c.n, k, @name_extras, "txt")
    end
    
    def pimage_filename(k)
      sprintf("%s/%03d_%03d_%s_pct.%s", @c.base+"/images", @c.n, k, @name_extras, "png")
    end
    
    def filename_block
      raise "No block provided!" unless block_given?
      @c.k.upto(@c.k2) do |i|
        filename = sprintf("%s/%03d_%03d_%s.%s", @c.base, @c.n, i, @name_extras, "txt")
        yield i, filename
      end
    end
    
    def pfilename_block
      raise "No block provided!" unless block_given?
      @c.k.upto(@c.k2) do |i|
        filename = sprintf("%s/%03d_%03d_%s_pct.%s", @c.base, @c.n, i, @name_extras, "txt")
        yield i, filename
      end
    end
    
    def image_filename_block
      raise "No block provided!" unless block_given?
      @c.k.upto(@c.k2) do |i|
        filename = sprintf("%s/%03d_%03d_%s.%s", @c.base+"/images", @c.n, i, @name_extras, "png")
        yield i, filename
      end
    end
    
  end
end