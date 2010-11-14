Input_file = "AllCommunicationPairs_users0Mto100M.txt"
#Input_file = "test2.txt"
celebrity_file = "celebrities.txt"
Citers_file_pref = "celeb_"
Citers_file_suff = ".txt"
Output_file_pref = "_dc"
DC_dir = "dcso"

if __FILE__ == $0
  
  Dir.mkdir(DC_dir) unless File.directory? DC_dir
  
  celebrity_file = ARGV[0] if ARGV.length > 0
  
  File.open(celebrity_file, "r") do |cfile|
    while line = cfile.gets
      a = line.split[0]
      
      puts "Doing DC for #{a}"

      citers_file = Citers_file_pref + a + Citers_file_suff
      output_file = DC_dir+"/"+Citers_file_pref + a + Output_file_pref + Citers_file_suff
  
      # Build list of citers
      citers = Hash.new({})
      citer_list = {}
      file = File.new(citers_file, "r")
      while line = file.gets
        parts = line.split(' ')
        citer_list[parts[0].to_i] = parts[1].to_i
      end
      file.close
      
      puts "Built list of citers"
      #p citer_list
  
      # Build lists of people that citers cite
      file = File.new(Input_file)
      while line = file.gets
        parts = line.split(' ')
        c = parts[0].to_i
        d = parts[1].to_i
        if citer_list[c] != nil
          citers[c][d] = parts[3].to_i
        end
      end
      file.close
      
      puts "Built list of people that citers cite"
      #p citers
  
      # Find out if anyone before that citer cited that person before the person cited the target
      running_count = 0
      dc_count = 0
      ofile = File.new(output_file, "w")
      seen = Array.new
      file = File.new(citers_file, "r")
      while line = file.gets
        parts = line.split(' ')
        curr = parts[0].to_i
        time = parts[1].to_i
        found = 0
        seen.each do |s|
          if citers[s][curr] != nil && citers[s][curr] < time
            found += 1
          end
        end
        if found > 0
          print "O"
          dc_count += 1
        end
        seen << curr
        running_count += 1
        ofile.puts "%d %d" % [running_count, dc_count]
      end
      file.close
      ofile.close
      print "\n\n"
    end
  end
end