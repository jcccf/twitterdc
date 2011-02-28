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
  puts "Building the Rec/Unrec Outdegree counts for each person"
  am.build_rur_outdegrees
when 3
  puts "Building the Rec/Unrec Outdegree Plots for each person"
  am.build_rur_outdegrees_plot
when 4
  puts "Predicting Edges in the Graph using Degree"
  am.build_rur_prediction
when 5
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
else
  puts "Error in Stage Selection!"
end