# Build the predicted reciprocated and unreciprocated subgraphs based
# on the relative degree between nodes

require_relative "../atmessages.rb"

stage = (ARGV.length > 0 ? ARGV[0] : 1).to_i
n = (ARGV.length > 1 ? ARGV[1] : 100).to_i
k = (ARGV.length > 2 ? ARGV[2] : 10).to_i
k2 = (ARGV.length > 3 ? ARGV[3] : 30).to_i
e1 = (ARGV.length > 4 ? ARGV[4] : 60).to_i
e2 = (ARGV.length > 5 ? ARGV[5] : 95).to_i
st = (ARGV.length > 6 ? ARGV[6] : 5).to_i

am = AtMessages.new("../../AllCommunicationPairs_users0Mto100M.txt","../../data",n,k,k2)

puts "For #{n}, #{k} to #{k2}, with THETA = #{e1} to #{e2} in increments of #{st}..."

case stage
when 1
  puts "Finding Users with > #{n} messages..."
  atm.filter_users_by_messages
  puts "Finding Edges for #{n}..."
  atm.filter_graph_by_users
when 2
  puts "Building Graph and separating..."
  am.build_graph
when 3
  puts "Finding Strongly Connected Components..."
  am.find_scc
when 4
  puts "Building degrees and edges..."
  am.find_degrees_edges
when 10
  puts "Counting unique nodes for Reciprocated and Unreciprocated Graphs..."
  am.count_nodes_rec_unr
when 11
  puts "Plotting SCC Graphs..."
  am.plot_scc_graphs
else
  puts "Error in Stage Selection!"
end