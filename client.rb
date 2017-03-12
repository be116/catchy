require "curses"
require "./share.rb"

dest_addr = ""
port = 8888

if (ARGV.length != 1)
  puts "dest_addr"
  exit
end

dest_addr = ARGV[0]

Curses.init_screen
Game_manager.init
Game_manager.init_client(dest_addr, port)
begin
  while true

    Game_manager.update

  end
ensure
  Curses.close_screen
end