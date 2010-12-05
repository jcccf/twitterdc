input_dir = "ucomponent"

Dir.chdir(input_dir)
Dir.glob('*') do |fname|
  if !(fname.include? "cut")
    puts "Cutting %s" % fname
    if !system("cut -c 1-100 %s >> cut/%s" % [fname, fname])
      puts "Error occured for %s" % fname
    end
  end
end