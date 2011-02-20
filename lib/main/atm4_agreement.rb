require_relative "../atmessages.rb"

n = (ARGV.length > 0 ? ARGV[0] : 100).to_i
k = (ARGV.length > 1 ? ARGV[1] : 10).to_i
k2 = (ARGV.length > 2 ? ARGV[2] : 30).to_i
e1 = (ARGV.length > 3 ? ARGV[3] : 70).to_i
e2 = (ARGV.length > 4 ? ARGV[4] : 95).to_i
st = (ARGV.length > 5 ? ARGV[5] : 5).to_i

am = AtMessages.new("../../AllCommunicationPairs_users0Mto100M.txt","../../data",n,k,k2)

puts "Testing Agreement for #{n}, #{k} to #{k2} for e=#{e1} to #{e2} in steps of #{st}..."
am.degree_agreement_with_generated_graphs(e1,e2,st)