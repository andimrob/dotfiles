#!/usr/bin/env ruby
#  _ __  _ __ _   _ _ __ ___
# | '_ \| '__| | | | '__/ __|
# | |_) | |  | |_| | | | (__
# | .__/|_|   \__, |_|  \___|
# |_|         |___/

%w[pp awesome_print gist pry-doc].each do |gem_name|
  begin
    require gem_name
    AwesomePrint.pry! if gem_name == 'awesome_print'
  rescue LoadError => e
    puts "'#{gem_name}' gem not found. Try typing 'gem install #{gem_name}'"
  end
end

# === EDITOR ===
Pry.editor = 'code'

Pry.config.color = true
# Pry.config.prompt = Pry::NAV_PROMPT

# Pry.config.history.file = "~/.pry_history"

Pry.config.commands.alias_command "h", "hist -T 20", desc: "Last 20 commands"
Pry.config.commands.alias_command "hg", "hist -T 20 -G", desc: "Up to 20 commands matching expression"
Pry.config.commands.alias_command "hG", "hist -G", desc: "Commands matching expression ever used"
Pry.config.commands.alias_command "hr", "hist -r", desc: "hist -r <command number> to run a command"

Pry::Commands.block_command "noconflict", "Rename step to sstep and next to nnext" do
  Pry::Commands.rename_command("nnext", "next")
  Pry::Commands.rename_command("bbreak", "break")
end

Pry::Commands.block_command "unnoconflict", "Revert to normal next and break" do
  Pry::Commands.rename_command("next", "nnext")
  Pry::Commands.rename_command("break", "bbreak")
end

# Hit Enter to repeat last command
Pry::Commands.command /^$/, "repeat last command" do
  _pry_.run_command Pry.history.to_a.last
end

Pry::Commands.block_command 'pl', "Alias for 'play -l'" do |lines|
  _pry_.run_command("play -l #{lines}")
end

# === CUSTOM COMMANDS ===
# from: https://gist.github.com/1297510
default_command_set = Pry::CommandSet.new do
  command "copy", "Copy argument to the clip-board" do |str|
     IO.popen('pbcopy', 'w') { |f| f << str.to_s }
  end

  command "clear" do
    system 'clear'
    if ENV['RAILS_ENV']
      output.puts "Rails Environment: " + ENV['RAILS_ENV']
    end
  end

  command "caller_method" do |depth|
    depth = depth.to_i || 1
    if /^(.+?):(\d+)(?::in `(.*)')?/ =~ caller(depth+1).first
      file   = Regexp.last_match[1]
      line   = Regexp.last_match[2].to_i
      method = Regexp.last_match[3]
      output.puts [file, line, method]
    end
  end
end

Pry.config.commands.import default_command_set

# === CONVENIENCE METHODS ===
# Stolen from https://gist.github.com/807492
# Use Array.toy or Hash.toy to get an array or hash to play with
class Array
  def self.toy(n=10, &block)
    block_given? ? Array.new(n,&block) : Array.new(n) {|i| i+1}
  end
end

class Hash
  def self.toy(n=10)
    Hash[Array.toy(n).zip(Array.toy(n){|c| (96+(c+1)).chr})]
  end
end

puts "Using Ruby v#{RUBY_VERSION}"
puts "Loading #{__FILE__}"
