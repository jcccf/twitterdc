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
  am.decision_tree_generate(k,"all")
when 3
  puts "Testing Generated Tree of #{k} on #{k2}"
  am.decision_tree_evaluate(k,k2)
when 5
  puts "Combining..."
  am.generate_csv_files_from_parts(k, "all2", ['simple','paths','link'])
when 6
  puts "Generating Combined Decision Tree for #{k}"
  am.decision_tree_generate(k,"all2")
when 7
  puts "Combining everything..."
  am.generate_csv_files_from_parts(k, "all3", ['simple','paths','link','vw'])
when 8
  puts "Generating Combined Everything Decision Tree for #{k}"
  am.decision_tree_generate(k,"all3")
when 9
  puts "Combining (vw,paths,link)..."
  am.generate_csv_files_from_parts(k, "all2x", ['vw','paths','link'])
when 10
  puts "Generating Combined (vw,paths,link) Decision Tree for #{k}"
  am.decision_tree_generate(k,"all2x")
when 11
  puts "Generating Simple CSV for #{k}"
  am.generate_csv_files_simple(k)
when 12
  puts "Generating Simple Decision Tree for #{k}"
  am.decision_tree_generate(k,"simple")
when 21
  puts "Generating Paths CSV for #{k}"
  am.generate_csv_files_paths(k)
when 22
  puts "Generating Paths Decision Tree for #{k}"
  am.decision_tree_generate(k,"paths")
when 31
  puts "Generating Link CSV for #{k}"
  am.generate_csv_files_link(k)
when 32
  puts "Generating Links Decision Tree for #{k}"
  am.decision_tree_generate(k,"link")
when 41
  puts "Generating VW CSV for #{k}"
  am.generate_csv_files_vw(k)
when 42
  puts "Generating VW Decision Tree for #{k}"
  am.decision_tree_generate(k,"vw")
when 51
  puts "Generating Filtered Indegree CSV for #{k}"
  am.generate_csv_files_indegree(k)
when 52
  puts "Generating Filtered Indegree Decision Tree for #{k}"
  am.decision_tree_generate(k,"indegree")
when 100
  puts "Generating Combined (vw,paths,link) Decision Tree for #{k}"
  am.decision_tree_generate_rev(k,"all2x")
when 101
  puts "Generating Combined Decision Tree for #{k}"
  am.decision_tree_generate_rev(k,"all2")
when 102
  puts "Generating Combined Everything Decision Tree for #{k}"
  am.decision_tree_generate_rev(k,"all3")
when 103
  puts "Generating Simple Decision Tree for #{k}"
  am.decision_tree_generate_rev(k,"simple")
when 104
  puts "Generating Paths Decision Tree for #{k}"
  am.decision_tree_generate_rev(k,"paths")
when 105
  puts "Generating Links Decision Tree for #{k}"
  am.decision_tree_generate_rev(k,"link")
when 106
  puts "Generating VW Decision Tree for #{k}"
  am.decision_tree_generate_rev(k,"vw")
else
  puts "Error in Stage Selection!"
end