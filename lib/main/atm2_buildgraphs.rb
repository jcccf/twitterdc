require_relative "../atmessages.rb"

k = ARGV.length > 0 ? ARGV[0] : 10

am = AtMessages.new("../../data/atmessages_graph_100.txt",k)
puts "Building Graph for #{k}..."
am.build_graph
puts "Separating into Reciprocated and Unreciprocated Graphs for #{k}..."
am.to_file("../../data/atmessages_graph_100_"+sprintf("%03d",k)+"_rec.txt","../../data/atmessages_graph_100_"+sprintf("%03d",k)+"_unr.txt")