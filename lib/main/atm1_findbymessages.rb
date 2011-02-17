require_relative "../atmessages.rb"

n = (ARGV.length > 0 ? ARGV[0] : 100).to_i

atm = AtMessages.new("../../AllCommunicationPairs_users0Mto100M.txt","../../data",n,10)

puts "Finding Users with > #{n} messages..."
atm.filter_users_by_messages

puts "Finding Edges for #{n}..."
atm.filter_graph_by_users