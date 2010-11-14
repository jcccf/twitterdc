require 'constants'

Limit = 1000

if __FILE__ == $0
  people = {}
  
  file = File.new(Constants::In_file,"r")
  while line = file.gets
    parts = line.split(' ')
    # puts "%s @ed %s at time %s" % [parts[0], parts[1], parts[3]]
    if(people.has_key?(parts[1]))
      people[parts[1]] += 1
    else
      people[parts[1]] = 1
    end
  end
  file.close
  
  pfile = File.new(Constants::Celeb_file,"w")
  people.sort { |a,b| a[1] <=> b[1] }.reverse[0,Limit].each do |person|
    pfile.puts "%s %s" % [person[0],person[1]]
  end
  pfile.close
  
end