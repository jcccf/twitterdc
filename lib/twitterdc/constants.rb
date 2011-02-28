module TwitterDc
  class Constants
    attr_reader :base, :n, :k, :k2, :e1, :e2, :st
    
    def initialize(base_dir, n, k, k2, e1=60, e2=95, st=5)
      @base = base_dir
      @n = n
      @k = k
      @k2 = k2
      @e1 = e1
      @e2 = e2
      @st = st
    end

    # List of people and also the number of messages each person sent (in total in the full graph)
    def people
      @base+"/atmsg_people_"+sprintf("%03d",@n)+".txt"
    end
    
    # The subgraph that everything else is based on
    def graph
      @base+"/atmsg_graph_"+sprintf("%03d",@n)+".txt"
    end
    
    # Number of messages each person sent/received in the subgraph
    def people_msg
      @base+"/atmsg_people_"+sprintf("%03d",@n)+"_msg.txt"
    end

    # Reciprocated Graph File (with Reptition)
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
    
    # Reciprocated Graph File (No Repetitions)
    def reciprocated_norep(eye=@k)
      if block_given?
        @k.upto(@k2) do |i|
          filename = @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_recn.txt"
          yield i, filename
        end
      else
        @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",eye)+"_recn.txt"
      end
    end
    
    # Reciprocated Node Count File
    def reciprocated_node_count
      @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_rec_"+sprintf("%03d",@k)+"-"+sprintf("%03d",@k2)+"_ncount.txt"
    end
    
    def unreciprocated_node_count
      @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_unr_"+sprintf("%03d",@k)+"-"+sprintf("%03d",@k2)+"_ncount.txt"
    end
    
    # Reciprocated and Unreciprocated Edge Count File
    def rur_edge_count
      @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_rur_"+sprintf("%03d",@k)+"-"+sprintf("%03d",@k2)+"_ecount.txt"
    end
    
    # Number of edges that each person participates in that are reciprocated or unreciprocated
    def rur_outdegrees(eye=@k)
      if block_given?
        @k.upto(@k2) do |i|
          filename = @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_rur_outdegrees.txt"
          yield i, filename
        end
      else
        @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",eye)+"_rur_outdegrees.txt"
      end
    end
    
    # Number of edges that each person participates in that are reciprocated or unreciprocated
    def rur_outdegrees_image(eye=@k)
      if block_given?
        @k.upto(@k2) do |i|
          filename = @base+"/images/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_rur_outdegrees.png"
          yield i, filename
        end
      else
        @base+"/images/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",eye)+"_rur_outdegrees.png"
      end
    end
    
    # Number of edges that each person participates in that are reciprocated or unreciprocated
    def rur_outdegrees_image_alt(eye=@k)
      if block_given?
        @k.upto(@k2) do |i|
          filename = @base+"/images/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_rur2_outdegrees.png"
          yield i, filename
        end
      else
        @base+"/images/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",eye)+"_rur2_outdegrees.png"
      end
    end
    
    def rur_pred_degree(eye=@k)
      if block_given?
        @k.upto(@k2) do |i|
          filename = @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_rur_pred.txt"
          yield i, filename
        end
      else
        @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",eye)+"_rur_pred.txt"
      end
    end
    
    def rur_pred_degree_image(eye=@k)
      if block_given?
        @k.upto(@k2) do |i|
          filename = @base+"/images/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_rur_pred.png"
          yield i, filename
        end
      else
        @base+"/images/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",eye)+"_rur_pred.png"
      end
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
    
    def scc_of_unreciprocated_pred_deg(eye)
      @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_unr_pred_deg_"+sprintf("%03d",eye)+"_scc.txt"
    end
    
    def reciprocated_pred_deg(eye)
      @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_rec_pred_deg_"+sprintf("%03d",eye)+".txt"
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
    
    def cc_of_unreciprocated(eye=@k)
      if block_given?
        @k.upto(@k2) do |i|
          filename = @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",i)+"_unr_cc.txt"
          yield i, filename
        end
      else
        @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",eye)+"_unr_cc.txt"
      end
    end
    
    def images_dir
      @base+"/images"
    end
    
    def scc_of_unreciprocated_image
      @base+"/images/atmsg_graph_"+sprintf("%03d",@n)+"_"+sprintf("%03d",@k)+"-"+sprintf("%03d",@k2)+"_unr_scc.png"
    end
    
    def reciprocated_agreement_image
      @base+"/images/atmsg_graph_"+sprintf("%03d",@n)+"_agreement_rec.png"
    end
    
    def unreciprocated_agreement_image
      @base+"/images/atmsg_graph_"+sprintf("%03d",@n)+"_agreement_unr.png"
    end
    
    def agreement(eye)
      @base+"/atmsg_graph_"+sprintf("%03d",@n)+"_agreement_p#{eye}.txt"
    end
    
    def degrees
      @base+"/atmsg_people_"+sprintf("%03d",@n)+"_degree.txt"
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