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
Game_manager.init_client(dest_addr, port)
Game_manager.init
begin
  
  while true

    if !Game_manager.update
      break
    end

  end

ensure
  Curses.close_screen
end