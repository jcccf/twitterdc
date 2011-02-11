require 'set'

class AtMessages
  
  # Output the set of users who have sent num or more messages.
  def self.filter_users_by_messages(filename_graph,filename_output,num)
    people = {}
    File.open(filename_graph,"r") do |file|
      while line = file.gets
        parts = line.split(' ', 2)
        people[parts[0]] ||= 0
        people[parts[0]] += 1
      end
    end
    
    File.open(filename_output+"~","w") do |ofile|
      people.each do |k,v|
        ofile.puts "#{k} #{v}" if v >= num
      end
    end
    
    File.rename(filename_output+"~",filename_output)
  end
  
  # Output the subgraph of filename consisting of edges starting with users listed in filename_users
  def self.filter_graph_by_users(filename_graph,filename_users,filename_output)
    # Read in people
    people = Set.new
    File.open(filename_users,"r") do |file|
      while line = file.gets
        parts = line.split(' ', 2)
        people.add parts[0]
      end
    end
    
    # Filter people from the original graph
    File.open(filename_output+"~","w") do |ofile|
      File.open(filename_graph) do |file|
        while line = file.gets
          parts = line.split(' ', 2)
          ofile.puts line if people.include? parts[0]
        end
      end
    end
    
    File.rename(filename_output+"~", filename_output)
  end
  
end