require 'optparse'
require_relative "../atmessages2.rb"

n, k, k2, e1, e2, st = 1000, 10, 30, 0, 100, 5
type = :percentiles
plot = true
heuristic = nil
filter_name = nil

opts = OptionParser.new do |opts|
  opts.on("-k") { |ok| k = ok }
  opts.on("-k2") { |ok2| k2 = ok2 }
  opts.on("-e1") { |oe1| e1 = oe1 }
  opts.on("-e2") { |oe2| e2 = oe2 }
  opts.on("-st") { |ost| st = ost }
  
  # N = ?
  opts.on("-n", "--number NUMBER", Integer) do |on|
    n = on
  end
  
  # What type of test?
  opts.on("-t", "--type TYPE", Integer) do |t|
    type = case t
    when 1 then :percentiles
    when 2 then :directed_percentiles
    when 3 then :directed_onesided_percentiles
    when 4 then :directed_v_percentiles
    else raise "Invalid -t passed"
    end
  end
  
  # Do a prediction?
  opts.on("-p", "--pred", "Do a prediction instead of a plot") do |p|
    plot = false
  end
  
  # Choose a heuristic and run!
  opts.on("-h", "--heuristic HEURISTIC", "What heuristic?") do |h|
    heuristic = h
  end
  
  # Choose a heuristic and run!
  opts.on("-f", "--filter FILTER", "What filter?") do |f|
    filter_name = f.to_sym
  end
end
opts.parse!(ARGV)

if heuristic
  am = AtMessages2.new("../../AllCommunicationPairs_users0Mto100M.txt","../../data",n,k,k2,e1,e2,st)
  puts "For #{n}, #{k} to #{k2}, with THETA = #{e1} to #{e2} in increments of #{st}..."
  puts "Attempting heuristic for #{heuristic} #{type.to_s} #{filter_name.to_s}"
  if plot
    puts "Doing Plot...."
    if filter_name
      am.build_rur_prediction_plot(heuristic.to_sym,type,filter_name)
    else
      am.build_rur_prediction_plot(heuristic.to_sym,type)
    end
  else
    puts "Doing Prediction..."
    if filter_name
      am.build_rur_prediction(heuristic.to_sym,type,filter_name)
    else
      am.build_rur_prediction(heuristic.to_sym,type)
    end
  end
end