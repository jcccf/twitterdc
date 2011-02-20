module TwitterDc
  class Constants
    attr_accessor :base
    
    def initialize(base_dir, n, k, k2)
      @base = base_dir
      @n = n
      @k = k
      @k2 = k2
    end

    def reciprocated(eye=@k)
      if block_given?
        @k.upto(@k2) do |i|
          filename = @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_rec.txt"
          yield i, filename
        end
      else
        @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",eye)+"_rec.txt"
      end
    end
    
    def reciprocated_node_count
      @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",@k)+"-"+sprintf("%03d",@k2)+"_rec_ncount.txt"
    end
    
    def unreciprocated(eye=@k)
      if block_given?
        @k.upto(@k2) do |i|
          filename = @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_unr.txt"
          yield i, filename
        end
      else
        @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",eye)+"_unr.txt"
      end
    end
    
    def unreciprocated_pred_deg(eye)
      @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_unr_pred_deg_"+sprintf("%03d",eye)+".txt"
    end
    
    def reciprocated_pred_deg(eye)
      @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_rec_pred_deg_"+sprintf("%03d",eye)+".txt"
    end
    
    def unreciprocated_node_count
      @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",@k)+"-"+sprintf("%03d",@k2)+"_unr_ncount.txt"
    end
    
    def scc_of_unreciprocated(eye=@k)
      if block_given?
        @k.upto(@k2) do |i|
          filename = @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_unr_scc.txt"
          yield i, filename
        end
      else
        @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",eye)+"_unr_scc.txt"
      end
    end
    
    def images_dir
      @base+"/images"
    end
    
    def scc_of_unreciprocated_image
      @base+"/images/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",@k)+"-"+sprintf("%03d",@k2)+"_unr_scc.png"
    end
    
    def agreement(eye)
      @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_agreement_p#{eye}.txt"
    end
    
  end
end

# puts "hello"
# include TwitterDc
# c = Constants.new("heasd",10,2,20)
# c.scc_of_unreciprocated do |i,f|
#   puts "#{i} AND #{f}"
# end
# 
# puts c.scc_of_unreciprocated(1000)