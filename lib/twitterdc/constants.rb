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
    
    # Prediction based on degree
    def rur_pred_degree(eye=@k, &block)
      base_n_k("rur_pred",eye, &block)
    end
    
    def rur_pred_degree_image(eye=@k, &block)
      base_n_k("rur_pred",eye, true, &block)
    end
    
    # Prediction based on in-messages
    def rur_pred_inmsg(eye=@k, &block)
      base_n_k("rur_pred_inmsg",eye, &block)
    end
    
    def rur_pred_inmsg_image(eye=@k, &block)
      base_n_k("rur_pred_inmsg",eye, true, &block)
    end
    
    # Prediction based on out-messages
    def rur_pred_outmsg(eye=@k, &block)
      base_n_k("rur_pred_outmsg",eye, &block)
    end
    
    def rur_pred_outmsg_image(eye=@k, &block)
      base_n_k("rur_pred_outmsg",eye, true, &block)
    end
    
    # Prediction based on in-messages / in-degree
    def rur_pred_msgdeg(eye=@k, &block)
      base_n_k("rur_pred_msgdeg",eye, &block)
    end
    
    # Image of prediction based on in-messages / in-degree
    def rur_pred_msgdeg_image(eye=@k, &block)
      base_n_k("rur_pred_msgdeg",eye, true, &block)
    end
    
    # Prediction based on ratio of indegree to outdegree
    def rur_pred_inoutdeg(eye=@k, &block)
      base_n_k("rur_pred_inoutdeg",eye, &block)
    end
    
    # Image of prediction based on ratio of indegree to outdegree
    def rur_pred_inoutdeg_image(eye=@k, &block)
      base_n_k("rur_pred_inoutdeg",eye, true, &block)
    end
    
    # Prediction based on number of mutual friends
    def rur_pred_mutual(eye=@k, &block)
      base_n_k("rur_pred_mutual",eye, &block)
    end
    
    # Image of prediction based on number of mutual friends
    def rur_pred_mutual_image(eye=@k, &block)
      base_n_k("rur_pred_mutual",eye, true, &block)
    end
    
    # Prediction based on number of mutual friends (indegree)
    def rur_pred_mutualin(eye=@k, &block)
      base_n_k("rur_pred_mutualin",eye, &block)
    end
    
    # Image of prediction based on number of mutual friends (indegree)
    def rur_pred_mutualin_image(eye=@k, &block)
      base_n_k("rur_pred_mutualin",eye, true, &block)
    end
    
    # Prediction based on number of mutual friends (indegree) (Jaccard's Coefficient)
    def rur_pred_mutualin_nbrs(eye=@k, &block)
      base_n_k("rur_pred_mutualin_nbrs",eye, &block)
    end
    
    # Image of prediction based on number of mutual friends (indegree) (Jaccard's Coefficient)
    def rur_pred_mutualin_nbrs_image(eye=@k, &block)
      base_n_k("rur_pred_mutualin_nbrs",eye, true, &block)
    end
    
    # Prediction based on number of mutual friends (indegree) (Absolute number of mutual friends)
    def rur_pred_mutualin_abs(eye=@k, &block)
      base_n_k("rur_pred_mutualin_abs",eye, &block)
    end
    
    # Image of prediction based on number of mutual friends (indegree) (Absolute number of mutual friends)
    def rur_pred_mutualin_abs_image(eye=@k, &block)
      base_n_k("rur_pred_mutualin_abs",eye, true, &block)
    end
    
    # Prediction based on number of mutual friends (indegree) (Adamic/Adar)
    def rur_pred_mutualin_wnbrs(eye=@k, &block)
      base_n_k("rur_pred_mutualin_wnbrs",eye, &block)
    end
    
    # Image of prediction based on number of mutual friends (indegree) (Adamic/Adar)
    def rur_pred_mutualin_wnbrs_image(eye=@k, &block)
      base_n_k("rur_pred_mutualin_wnbrs",eye, true, &block)
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
    
    #
    # Decision Tree Constants
    #
    
    def csv_training(eye=@k, &block)
      base_n_k("csv_training",eye, &block)
    end
    
    def csv_test(eye=@k, &block)
      base_n_k("csv_test",eye, &block)
    end
    
    def decision_rules(eye=@k, &block)
      base_n_k("decision_rules",eye, &block)
    end
    
    def decision_results(eye=@k, &block)
      base_n_k("decision_results",eye, &block)
    end
    
    def decision_results_bon(i, eye=@k, &block)
      base_n_k("decision_results_basedon_"+i.to_s, eye, &block)
    end
    
  end
end
# 
# puts "hello"
# include TwitterDc
# c = Constants.new("heads",10,2,20,0,100,5)
# puts c.range_array