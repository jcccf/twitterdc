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

case stage
when 1
  puts "Building degrees and edges for #{n}"
  am.find_degrees_edges
when 2
  puts "Testing Agreement for #{n}, #{k} to #{k2} for e=#{e1} to #{e2} in steps of #{st}..."
  am.degree_agreement_with_generated_graphs(e1,e2,st)
when 3
  puts "Buliding predicted reciprocated and unreciprocated subgraphs for #{n}"
  am.build_prediction_on_degree(e1,e2,st)
when 4
  puts "Building SCC for predicted unreciprocated subgraphs for #{n}"
  am.find_scc_on_degree(e1,e2,st)
else
  puts "Error in Stage Selection!"
end