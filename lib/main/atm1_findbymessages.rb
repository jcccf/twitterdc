require_relative "../atmessages.rb"

n = ARGV.length > 0 ? ARGV[0] : 100

puts "Finding Users with > #{n} messages..."
AtMessages.filter_users_by_messages("../../AllCommunicationPairs_users0Mto100M.txt","../../data/atmessages_people_"+sprintf("%03d",n)+".txt",n)

puts "Finding Edges for #{n}..."
AtMessages.filter_graph_by_users("../../AllCommunicationPairs_users0Mto100M.txt","../../data/atmessages_people_"+sprintf("%03d",k)+".txt","../../data/atmessages_graph_"+sprintf("%03d",k)+".txt")