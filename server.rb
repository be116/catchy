require "curses"
require "./share.rb"

port = 8888

Curses.init_screen
Game_manager.init_server(port)
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