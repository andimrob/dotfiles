begin
  require 'awesome_print'
  AwesomePrint.pry!
rescue LoadError => e
  puts "ap gem not found.  Try typing 'gem install awesome_print' to get super-fancy output."
end
