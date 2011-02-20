# Plot the charts for the size of the SCC of the unreciprocated subgraphs

require_relative "../atmessages.rb"

stage = (ARGV.length > 0 ? ARGV[0] : 1).to_i
n = (ARGV.length > 1 ? ARGV[1] : 100).to_i
k = (ARGV.length > 2 ? ARGV[2] : 10).to_i
k2 = (ARGV.length > 2 ? ARGV[3] : 30).to_i

am = AtMessages.new("../../AllCommunicationPairs_users0Mto100M.txt","../../data",n,k,k2)

case stage
when 1
  puts "Counting unique nodes for Reciprocated and Unreciprocated Graphs for #{n}, #{k} to #{k2}..."
  am.count_nodes_rec_unr
when 2
  puts "Plotting SCC Graphs for #{n} from #{k} to #{k2}"
  am.plot_scc_graphs
else
  puts "Error in stage"
end