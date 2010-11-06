Input_file = "test2.txt"
Citers_file = "celeb_20.txt"
Output_file = Citers_file+".dc.txt"

if __FILE__ == $0
  
  # Build list of citers
  citers = {}
  citer_list = {}
  file = File.new(Citers_file, "r")
  while line = file.gets
    parts = line.split(' ')
    citer_list[parts[0]] = parts[1]
  end
  file.close
  
  # Build lists of people that citers cite
  file = File.new(Input_file)
  while line = file.gets
    parts = line.split(' ')
    c = parts[0]
    d = parts[1]
    if citer_list[c] != nil
      if citers[c] == nil
        citers[c] = {}
      end
      citers[c][d] = parts[3]
    end
  end
  file.close
  
  # Find out if anyone before that citer cited that person before the person cited the target
  running_count = 0
  dc_count = 0
  ofile = File.new(Output_file, "w")
  seen = Array.new
  file = File.new(Citers_file, "r")
  while line = file.gets
    parts = line.split(' ')
    curr = parts[0]
    time = parts[1]
    found = 0
    seen.each do |s|
      if citers[s][curr] != nil && citers[s][curr] < time
        found += 1
      end
    end
    if found > 0
      # puts "Directed Closure Found!"
      dc_count += 1
    end
    seen << parts[0]
    running_count += 1
    ofile.puts "%d %d" % [running_count, dc_count]
  end
  file.close
  ofile.close
  
end