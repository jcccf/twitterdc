# 2nd Meeting Discussion

require_relative "../atmessages2.rb"

stage = (ARGV.length > 0 ? ARGV[0] : 1).to_i
n = (ARGV.length > 1 ? ARGV[1] : 100).to_i
k = (ARGV.length > 2 ? ARGV[2] : 10).to_i
k2 = (ARGV.length > 3 ? ARGV[3] : 30).to_i
e1 = (ARGV.length > 4 ? ARGV[4] : 0).to_i
e2 = (ARGV.length > 5 ? ARGV[5] : 100).to_i
st = (ARGV.length > 6 ? ARGV[6] : 5).to_i

am = AtMessages2.new("../../AllCommunicationPairs_users0Mto100M.txt","../../data",n,k,k2,e1,e2,st)

puts "For #{n}, #{k} to #{k2}, with THETA = #{e1} to #{e2} in increments of #{st}..."

case stage
when 1
  puts "Rebuilding Rec Graphs"
  am.rebuild_rec_graph
when 2
  puts "Building Edge Files for Rec and Unrec Graphs"
  am.build_rur_edge_count(k)
when 3
  puts "Building the Rec/Unrec Outdegree counts for each person"
  am.build_rur_outdegrees
when 4
  puts "Building the Rec/Unrec Outdegree Plots for each person"
  am.build_rur_outdegrees_plot
when 5
  puts "Predicting Edges in the Graph using Degree"
  am.build_rur_prediction
when 6
  puts "Building the Edge Prediction Plots"
  am.build_rur_prediction_plot
when 10
  puts "Building Weakly Connected Components for the Unrec Subgraphs"
  am.build_unrec_connected_components
when 11
  puts "Plotting Strongly and Weakly Connected Components for Unrec Subgraphs"
  am.plot_scc_wcc_graphs
when 20 # Depends on Stage 1
  puts "Finding Edge Counts in Rec/Unrec Subgraphs"
  am.build_rur_edge_count
when 30
  puts "Build Message Counts (not that of the whole complete graph)"
  am.build_message_count
when 31
  puts "Predicting Edges in the Graph using In Messages"
  am.build_rur_prediction(:inmsg)
when 32
  puts "Building the Edge Prediction Plots using In Messages"
  am.build_rur_prediction_plot(:inmsg)
when 33
  puts "Predicting Edges in the Graph using Out Messages"
  am.build_rur_prediction(:outmsg)
when 34
  puts "Building the Edge Prediction Plots using Out Messages"
  am.build_rur_prediction_plot(:outmsg)
when 35
  puts "Predicting Edges in the Graph using In Messages/In Degree"
  am.build_rur_prediction(:msgdeg)
when 36
  puts "Building the Edge Prediction Plots using In Messages/In Degree"
  am.build_rur_prediction_plot(:msgdeg)
when 37
  puts "Predicting Edges in the Graph using Outdegree/Indegree Ratio"
  am.build_rur_prediction(:inoutdeg)
when 38
  puts "Building the Edge Prediction Plots using Outdegree/Indegree Ratio"
  am.build_rur_prediction_plot(:inoutdeg)
when 40
  puts "Predicting Edges in the Graph using Mutual Sends / Outdegree"
  am.build_rur_prediction(:mutual)
when 41
  puts "Building the Edge Prediction Plots using Mutual Sends / Outdegree"
  am.build_rur_prediction_plot(:mutual)
when 42
  puts "Predicting Edges in the Graph using Mutual Receives / Indegree"
  am.build_rur_prediction(:mutualin)
when 43
  puts "Building the Edge Prediction Plots using Mutual Receives / Indegree"
  am.build_rur_prediction_plot(:mutualin)
when 44
  puts "Predicting Edges in the Graph using Mutual Receives / Neighbors"
  am.build_rur_prediction(:mutualin_nbrs)
when 45
  puts "Building the Edge Prediction Plots using Mutual Receives / Neighbors"
  am.build_rur_prediction_plot(:mutualin_nbrs)
when 46
  puts "Predicting Edges in the Graph using Mutual Receives"
  am.build_rur_prediction(:mutualin_abs)
when 47
  puts "Building the Edge Prediction Plots using Mutual Receives"
  am.build_rur_prediction_plot(:mutualin_abs)
when 48
  puts "Predicting Edges in the Graph using Mutual Receives (Weighted)"
  am.build_rur_prediction(:mutualin_wnbrs)
when 49
  puts "Building the Edge Prediction Plots using Mutual Receives (Weighted)"
  am.build_rur_prediction_plot(:mutualin_wnbrs)
when 50
  puts "Predicting Edges in the Graph using In Degree"
  am.build_rur_prediction(:degree)
when 51
  puts "Predicting Edges in the Graph using In Degree"
  am.build_rur_prediction_plot(:degree)
when 52
  puts "Predicting Edges in the Graph using Katz"
  am.build_rur_prediction(:katz)
when 53
  puts "Predicting Edges in the Graph using Katz"
  am.build_rur_prediction_plot(:katz)
when 54
  puts "Predicting Edges in the Graph using Rooted Unweighted Pagerank (Out)"
  am.build_rur_prediction(:pagerankout)
when 55
  puts "Predicting Edges in the Graph using Rooted Unweighted Pagerank (Out) Plot"
  am.build_rur_prediction_plot(:pagerankout)
when 56
  puts "Predicting Edges in the Graph using Katz (Undirected)"
  am.build_rur_prediction(:katzinout)
when 57
  puts "Predicting Edges in the Graph using Katz (Undirected)"
  am.build_rur_prediction_plot(:katzinout)
when 58
  puts "Predicting Edges in the Graph using Katz Out"
  am.build_rur_prediction(:katzout)
when 59
  puts "Predicting Edges in the Graph using Katz Out"
  am.build_rur_prediction_plot(:katzout)
when 60
  puts "Predicting Edges in the Graph using Katz 0.0005"
  am.build_rur_prediction(:katz0005)  
when 61
  puts "Predicting Edges in the Graph using Katz 0.0005"
  am.build_rur_prediction_plot(:katz0005)
when 62
  puts "Predicting Edges in the Graph using Katz 0.1"
  am.build_rur_prediction(:katz01)  
when 63
  puts "Predicting Edges in the Graph using Katz 0.1"
  am.build_rur_prediction_plot(:katz01)
when 64
  puts "Predicting Edges in the Graph using Preferential Attachment 0-1000"
  am.build_rur_prediction(:prefattach)  
when 65
  puts "Predicting Edges in the Graph using Preferential Attachment 0-1000"
  am.build_rur_prediction_plot(:prefattach)
when 66
  puts "Predicting Edges in the Graph using Preferential Attachment Percentiles"
  am.build_rur_prediction(:prefattach,:percentiles)  
when 67
  puts "Predicting Edges in the Graph using Preferential Attachment Percentiles"
  am.build_rur_prediction_plot(:prefattach,:percentiles)
when 68
  puts "Predicting Edges in the Graph using Katz Out Percentiles"
  am.build_rur_prediction(:katzout,:percentiles)
when 69
  puts "Predicting Edges in the Graph using Katz Out Percentiles"
  am.build_rur_prediction_plot(:katzout,:percentiles)
when 70
  puts "Predicting Edges in the Graph using Mutual Receives (Weighted) Percentiles"
  am.build_rur_prediction(:mutualin_wnbrs,:percentiles)
when 71
  puts "Building the Edge Prediction Plots using Mutual Receives (Weighted) Percentiles"
  am.build_rur_prediction_plot(:mutualin_wnbrs,:percentiles)
when 72
  puts "Predicting Edges in the Graph using Outdegree/Indegree Ratio Percentiles"
  am.build_rur_prediction(:inoutdeg,:percentiles)
when 73
  puts "Building the Edge Prediction Plots using Outdegree/Indegree Ratio Percentiles"
  am.build_rur_prediction_plot(:inoutdeg,:percentiles)
when 74
  puts "Predicting Edges in the Graph using Katz In Percentiles"
  am.build_rur_prediction(:katz,:percentiles)
when 75
  puts "Predicting Edges in the Graph using Katz In Percentiles"
  am.build_rur_prediction_plot(:katz,:percentiles)
when 76
  puts "Predicting Edges in the Graph using Katz InOut Percentiles"
  am.build_rur_prediction(:katzinout,:percentiles)
when 77
  puts "Predicting Edges in the Graph using Katz InOut Percentiles"
  am.build_rur_prediction_plot(:katzinout,:percentiles)
when 80
  puts "Predicting Edges in the Graph using Outdegree/Indegree Ratio Pct"
  am.build_rur_prediction(:inoutdeg,:percentiles)
when 81
  puts "Building the Edge Prediction Plots using Outdegree/Indegree Ratio Pct"
  am.build_rur_prediction_plot(:inoutdeg,:percentiles)
when 82
  puts "Predicting Edges in the Graph using Outdegree/Indegree Ratio Directed Pct"
  am.build_rur_prediction(:inoutdeg,:directed_percentiles)
when 83
  puts "Building the Edge Prediction Plots using Outdegree/Indegree Ratio Directed Pct"
  am.build_rur_prediction_plot(:inoutdeg,:directed_percentiles)
when 100
  puts "Building In/Out-degree Counts"
  am.build_degree_counts
else
  puts "Error in Stage Selection!"
end