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
    
    # Prediction given an undirected edge, separating into percentiles
    def pfilename(k)
      sprintf("%s/%03d_%03d_%s_pct.%s", @c.base, @c.n, k, @name_extras, "txt")
    end
    
    def pfilename_trans(k)
      sprintf("%s/%03d_%03d_%s_pct_trans.%s", @c.base, @c.n, k, @name_extras, "txt")
    end
    
    def pimage_filename(k)
      sprintf("%s/%03d_%03d_%s_pct.%s", @c.base+"/images", @c.n, k, @name_extras, "png")
    end
    
    # Prediction given a directed edge, separating into percentiles
    def dir_pfilename(k)
      sprintf("%s/%03d_%03d_%s_dir_pct.%s", @c.base, @c.n, k, @name_extras, "txt")
    end
    
    def dir_pfilename_trans(k)
      sprintf("%s/%03d_%03d_%s_dir_pct_trans.%s", @c.base, @c.n, k, @name_extras, "txt")
    end

    def dir_pimage_filename(k)
      sprintf("%s/%03d_%03d_%s_dir_pct.%s", @c.base+"/images", @c.n, k, @name_extras, "png")
    end
    
    # Prediction given a directed edge and only using one side, separating into percentiles
    def diro_pfilename(k)
      sprintf("%s/%03d_%03d_%s_diro_pct.%s", @c.base, @c.n, k, @name_extras, "txt")
    end
    
    def diro_pfilename_trans(k)
      sprintf("%s/%03d_%03d_%s_diro_pct_trans.%s", @c.base, @c.n, k, @name_extras, "txt")
    end

    def diro_pimage_filename(k)
      sprintf("%s/%03d_%03d_%s_diro_pct.%s", @c.base+"/images", @c.n, k, @name_extras, "png")
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
    
    def dir_pfilename_block
      raise "No block provided!" unless block_given?
      @c.k.upto(@c.k2) do |i|
        filename = sprintf("%s/%03d_%03d_%s_dir_pct.%s", @c.base, @c.n, i, @name_extras, "txt")
        yield i, filename
      end
    end
    
    def diro_pfilename_block
      raise "No block provided!" unless block_given?
      @c.k.upto(@c.k2) do |i|
        filename = sprintf("%s/%03d_%03d_%s_diro_pct.%s", @c.base, @c.n, i, @name_extras, "txt")
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