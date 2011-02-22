require_relative "../atmessages.rb"

n = (ARGV.length > 0 ? ARGV[0] : 100).to_i
k = (ARGV.length > 1 ? ARGV[1] : 10).to_i
k2 = (ARGV.length > 2 ? ARGV[2] : 30).to_i

am = AtMessages.new("../../AllCommunicationPairs_users0Mto100M.txt","../../data",n,k,k2)

puts "Finding Strongly Connected Components for #{n}, #{k} to #{k2}..."
am.find_scc