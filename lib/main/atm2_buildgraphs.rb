# For graphs where each node has sent more than n messages
# Find the subgraphs for which
# => Each node has at least sent k messages to another and vice versa
# => Each node has sent at least k messages to another but the other did not respond at all

require_relative "../atmessages.rb"

n = (ARGV.length > 0 ? ARGV[0] : 100).to_i
k = (ARGV.length > 1 ? ARGV[1] : 10).to_i
k2 = (ARGV.length > 2 ? ARGV[2] : 30).to_i

am = AtMessages.new("../../AllCommunicationPairs_users0Mto100M.txt","../../data",n,k,k2)

puts "Building Graph and separating for #{n}, #{k} to #{k2}..."
am.build_graph