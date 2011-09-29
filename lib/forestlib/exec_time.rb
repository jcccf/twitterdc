module ForestLib
	class ExecutionTime
	
		# Measures the execution of the block passed to it, outputting the runtime to the
		# given file
		def self.to_file(filename)
			start_time = Time.now
			yield
			end_time = Time.now - start_time
			File.open(filename, 'w') do |f|
				f.puts "%.8f" % end_time
			end
		end
	
	end
end

=begin
ForestLib::ExecutionTime.to_file("test.txt") do
	s = "asd"
	10000.times do
		s += "d"
	end
end
=end
