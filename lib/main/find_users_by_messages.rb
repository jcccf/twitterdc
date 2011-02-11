require_relative "../atmessages.rb"

puts "Finding Users..."
AtMessages.filter_users_by_messages("../../AllCommunicationPairs_users0Mto100M.txt","../../data/atmessages_people_100.txt",100)

puts "Finding Edges..."
AtMessages.filter_graph_by_users("../../AllCommunicationPairs_users0Mto100M.txt","../../data/atmessages_people_100.txt","../../data/atmessages_graph_100.txt")