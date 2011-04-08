# 3rd Meeting Discussion

require_relative "../atmessages3.rb"

stage = (ARGV.length > 0 ? ARGV[0] : 1).to_i
n = (ARGV.length > 1 ? ARGV[1] : 100).to_i
k = (ARGV.length > 2 ? ARGV[2] : 10).to_i
k2 = (ARGV.length > 3 ? ARGV[3] : 30).to_i
e1 = (ARGV.length > 4 ? ARGV[4] : 0).to_i
e2 = (ARGV.length > 5 ? ARGV[5] : 100).to_i
st = (ARGV.length > 6 ? ARGV[6] : 5).to_i

am = AtMessages3.new("../../AllCommunicationPairs_users0Mto100M.txt","../../data",n,k,k2,e1,e2,st)

puts "For #{n}, #{k} to #{k2}, with THETA = #{e1} to #{e2} in increments of #{st}..."

case stage
when 1
  puts "Generating CSV for #{k}"
  am.generate_csv_files(k)
when 2
  puts "Generating Decision Tree for #{k}"
  am.decision_tree_generate(k)
when 3
  puts "Testing Generated Tree of #{k} on #{k2}"
  am.decision_tree_evaluate(k,k2)
else
  puts "Error in Stage Selection!"
end