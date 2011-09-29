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
    
    def range_array
      a = []
      (e1..(e1+st)).each { |i| a << i }
      ((e1+2*st)..(e2-2*st)).step(st).each { |i| a << i }
      ([(e2-st),(e1+st+1)].max..e2).each { |i| a << i }
      a
    end
    
    def range_array_full
      a = []
      (e1..e2).each {|i| a << i}
      a
    end
    
    # Base template for files that depend only on n and k
    def base_n_k(suffix, eye=@k, is_image=false)
      folder = is_image ? @base+"/images" : @base
      extension = is_image ? "png" : "txt"
      if block_given?
        @k.upto(@k2) do |i|
          filename = sprintf("%s/%03d_%03d_%s.%s", folder, @n, i, suffix, extension)
          yield i, filename
        end
      else
        eye = eye.join("_") if eye.respond_to?('join')
        sprintf("%s/%03d_%03d_%s.%s", folder, @n, eye, suffix, extension)
      end
    end
    
    # List of people and also the number of messages each person sent (in total in the full graph)
    def people
      @base+"/people_"+sprintf("%03d",@n)+".txt"
    end
    
    # The subgraph that everything else is based on
    def graph
      @base+"/"+sprintf("%03d",@n)+".txt"
    end
    
    # Number of messages each person sent/received in the subgraph
    def people_msg
      @base+"/people_"+sprintf("%03d",@n)+"_msg.txt"
    end
    
    # List of edges in the graph of people who've sent >= n messages
    def edges
      @base+"/people_"+sprintf("%03d",@n)+"_edges.txt"
    end

    # Reciprocated Graph File (with Reptition)
    def reciprocated(eye=@k, &block)
      base_n_k("rec",eye, &block)
    end
    
    # Reciprocated Graph File (No Repetitions)
    def reciprocated_norep(eye=@k, &block)
      base_n_k("recn",eye, &block)
    end
    
    # Reciprocated Node Count File
    def reciprocated_node_count
      @base+"/"+sprintf("%03d",@n)+"_rec_"+sprintf("%03d",@k)+"-"+sprintf("%03d",@k2)+"_ncount.txt"
    end
    
    def unreciprocated_node_count
      @base+"/"+sprintf("%03d",@n)+"_unr_"+sprintf("%03d",@k)+"-"+sprintf("%03d",@k2)+"_ncount.txt"
    end
    
    def rur_msg_edges(eye=@k, &block)
      base_n_k("rur_msg_edges",eye, &block)
    end
    
    # Reciprocated and Unreciprocated Edge Count File
    def rur_edge_count
      @base+"/"+sprintf("%03d",@n)+"_rur_"+sprintf("%03d",@k)+"-"+sprintf("%03d",@k2)+"_ecount.txt"
    end
    
    # Number of edges that each person participates in that are reciprocated or unreciprocated
    def rur_outdegrees(eye=@k, &block)
      base_n_k("rur_outdegrees",eye, &block)
    end
    
    # Number of edges that each person participates in that are reciprocated or unreciprocated
    def rur_outdegrees_image(eye=@k, &block)
      base_n_k("rur_outdegrees",eye, true, &block)
    end
    
    # Number of edges that each person participates in that are reciprocated or unreciprocated
    def rur_outdegrees_image_alt(eye=@k, &block)
      base_n_k("rur2_outdegrees",eye, true, &block)
    end
    
    # Number of edges that each person participates in that are reciprocated or unreciprocated
    def rur_outdegrees_image_3d(eye=@k, &block)
      base_n_k("rur2_outdegrees_3d",eye, true, &block)
    end
    
    # Proportion of edges that each person participates in that are reciprocated or unreciprocated
    def rur_outdegrees_image_ratio(eye=@k, &block)
      base_n_k("rur_outdegrees_ratio",eye, true, &block)
    end
    
    # Unreciprocated Graph File
    def unreciprocated(eye=@k, &block)
      base_n_k("unr",eye, &block)
    end
    
    def unreciprocated_pred_deg(eye)
      @base+"/"+sprintf("%03d",@n)+"_unr_pred_deg_"+sprintf("%03d",eye)+".txt"
    end
    
    def scc_of_unreciprocated_pred_deg(eye)
      @base+"/"+sprintf("%03d",@n)+"_unr_pred_deg_"+sprintf("%03d",eye)+"_scc.txt"
    end
    
    def reciprocated_pred_deg(eye)
      @base+"/"+sprintf("%03d",@n)+"_rec_pred_deg_"+sprintf("%03d",eye)+".txt"
    end
    
    # Proportion in Strongly Connected Component in Unreciprocated Graph
    def scc_of_unreciprocated(eye=@k, &block)
      base_n_k("unr_scc",eye, &block)
    end
    
    # Proportion in Connected Component in Unreciprocated Graph
    def cc_of_unreciprocated(eye=@k, &block)
      base_n_k("unr_cc",eye, &block)
    end
    
    # Proportion in Connected Component in Unreciprocated Graph
    def decision_edges(eye=@k, &block)
      base_n_k("decedges_yaml",eye, &block)
    end
    
    def decision_edges_balanced(eye=@k, &block)
      base_n_k("decedges_yaml_bal",eye, &block)
    end
    
    def decision_edges_filter(filter_name, eye=@k, &block)
      base_n_k("decedges_yaml_"+filter_name.to_s,eye, &block)
    end
    
    def scc_of_unreciprocated_image
      @base+"/images/"+sprintf("%03d",@n)+"_"+sprintf("%03d",@k)+"-"+sprintf("%03d",@k2)+"_unr_scc.png"
    end
    
    def reciprocated_agreement_image
      @base+"/images/"+sprintf("%03d",@n)+"_agreement_rec.png"
    end
    
    def unreciprocated_agreement_image
      @base+"/images/"+sprintf("%03d",@n)+"_agreement_unr.png"
    end
    
    def agreement(eye)
      @base+"/"+sprintf("%03d",@n)+"_agreement_p#{eye}.txt"
    end
    
    def degrees
      @base+"/people_"+sprintf("%03d",@n)+"_degree.txt"
    end
    
  end
end
# 
# puts "hello"
# include TwitterDc
# c = Constants.new("heads",10,2,20,0,100,5)
# puts c.range_array