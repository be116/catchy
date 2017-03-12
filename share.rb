require 'curses'
include Curses
require "socket"

class Game_manager
  class << self
    # 制限時間
    @@limit     = 0
    @@max_limit = 10

    # 文字列収納
    @@enemy   = ""
    @@you     = ""
    @@message = ""
    @@support = ""
    
    @@enemies_buf = ""
    @@your_buf   = ""

    @@limits_title   = "limit   : "
    @@enemies_title  = "enemy   : "
    @@your_title     = "you     : "
    @@messages_title = "-- message --"

    @@win_message    = "you win"
    @@lose_message   = "you lose"

    @@enemies_turn   = true
    @@your_turn      = false

    @@game_over = false
    @@win       = false
    @@lose      = false

    @@sock = nil
    @@recv_thread = nil

    @@debug = ""

    @@now         = nil
    @@before_time = nil

    def ret_limits_row

      return @@limits_title + @@limit.to_s

    end

    def ret_enemies_row

      return @@enemies_title + @@enemy

    end

    def ret_your_row

      return @@your_title + @@you

    end

    def detect_turn

      if rand(10) % 2
        swap_turn
      end

      if @@your_turn
        @@sock.write("tell turn\r\nme\r\n")
      elsif @@enemies_turn
        @@sock.write("tell turn\r\nyou\r\n")
      end

    end

    def swap_turn

      @@your_turn    = !@@your_turn
      @@enemies_turn = !@@enemies_turn

      if @@your_turn
        @@you   = ""
      elsif @@enemies_turn
        @@enemy = ""
      end

      #@@limit = @@max_limit

    end

    def judge_for_limit

      if @@limit <= 0
        @@limit = 0
        @@game_over = true
        @@lose      = true
        @@support   = "(time over)"
      end

    end

    def judge_through_input

      if @@enemy.size < @@you.size
        return
      end

      pos = @@you.size - 1
      if @@you[pos] == @@enemy[pos]
      else
        @@game_over = true
        @@lose      = true
        @@support   = "(miss type)"
      end

    end

    def judge_at_throw

      if @@you.size < @@enemy.size 
        @@game_over = true
        @@lose      = true
        @@support   = "(lack of chars)"
      end

    end

    def input_you

      judge_for_limit

      if File.select([STDIN], [], [], 0) != nil 
        c = Curses.getch
        #Curses.delch
        if c.kind_of?(Fixnum)
        elsif c == nil
        elsif "a" <= c and c <= "z"
          if @@you.size >= @@enemy.size + 5
            return
          end
          @@your_buf += c
          @@you       = @@your_buf
          judge_through_input
          @@sock.write("type\r\n" + @@you + "\r\n")
        elsif c == " "
          @@your_buf  = ""
          judge_at_throw
          if @@lose
          else
            swap_turn
            @@sock.write("throw\r\n" + @@you + "\r\n")
          end
        end
      end

    end

    #def input_enemy

    #  if File.select([STDIN], [], [], 0) != nil 
    #    c = Curses.getch
    #    #Curses.delch
    #    if c.kind_of?(Fixnum)
    #    elsif c == nil
    #    elsif "a" <= c and c <= "z"
    #      @@enemies_buf += c
    #      @@enemy        = @@enemies_buf
    #    elsif c == " "
    #      @@enemies_buf  = ""
    #      swap_turn
    #    end  
    #  end

    #end

    def init

      Curses.noecho
      Curses.start_color
      Curses.init_pair(COLOR_WHITE, COLOR_WHITE, COLOR_BLACK)
      Curses.init_pair(COLOR_RED, COLOR_RED, COLOR_WHITE)

      @@now = Time.now
      @@before_time = @@now

      @@limit = @@max_limit

    end

    def init_client(dest_addr, port)

      @@sock = TCPSocket.open(dest_addr, port)
      @@recv_thread = Thread.new { do_recv }

    end

    def init_server(port)
    
      puts "wait for connection"
      sock0 = TCPServer.open(port)
      @@sock = sock0.accept

      @@recv_thread = Thread.new { do_recv }

      ##youかmeかランダムに
      detect_turn

    end

    

    # 通信相手からのメッセージの受信と処理
    def do_recv
  
      while true
        sock = @@sock

        command = sock.recv(65535)

        params = command.split("\r\n")
        
        #@@debug = ""
        #params.each { |param|
        #  @@debug += param + "\n"
        #}

        #@@debug += @@sock.eof?.to_s

        if params[0] == "tell turn"
          if params[1] == "you"
            @@your_turn    = true
            @@enemies_turn = false
          elsif params[1] == "me"
            @@your_turn    = false
            @@enemies_turn = true           
          end
        elsif params[0] == "type"
          @@enemy = params[1]
        elsif params[0] == "throw"
          @@enemy = params[1]
          swap_turn
        elsif params[0] == "finish"
          @@game_over = true
          if params[1] == "you win"
            @@win = true
          elsif params[1] == "you lose"
            @@lose = true
          end
          @@support = params[2]
          return
        end
      end

    end

    def update

      draw

      if @@win
        @@message = @@win_message
      elsif @@lose
        @@message = @@lose_message 
      end

      if @@game_over
        if @@lose
          @@sock.write("finish\r\nyou win\r\n"+@@support+"\r\n")
          #@@sock.close
        end
        #@@recv_thread.join
        while true
          @@debug = "push \"Space\" to close"
          draw
          if Curses.getch == " "
            return false
          end  
        end
      end

      @@now = Time.now
      delta_time = @@now - @@before_time
      @@before_time = @@now

      if @@your_turn
        @@limit -= delta_time
        if @@you.size < @@enemy.size
          @@message = "your turn : type the same chars as enemy"
        elsif @@you.size >= @@enemy.size
          @@message = "your turn : type (0 - 5) chars and push space to throw"
        end
        input_you
      elsif @@enemies_turn
        @@message   = "enemy's turn : wait for enemy"
        #input_enemy
      end

      return true

    end

    #画面描画
    def draw
      Curses.clear
      
      Curses.attron(color_pair(COLOR_WHITE)) {
        Curses.setpos(0, 0)
        Curses.addstr(ret_limits_row)
      }

      if @@enemies_turn
        Curses.attron(A_STANDOUT) {
          Curses.setpos(1, 0)
          Curses.addstr(ret_enemies_row)
        }
        Curses.setpos(2, 0)
        Curses.addstr(ret_your_row)
      elsif @@your_turn
        Curses.setpos(1, 0)
        Curses.addstr(ret_enemies_row)
        Curses.attron(A_STANDOUT) {
          Curses.setpos(2, 0)
          Curses.addstr(ret_your_row)
        }
      end
      
      Curses.setpos(3, 0)
      Curses.addstr(@@messages_title)
      
      Curses.setpos(4, 0)
      Curses.addstr(@@message)
      
      Curses.setpos(5, 0)
      Curses.addstr(@@support)

      Curses.setpos(6, 0)
      Curses.addstr(@@debug)
      
      Curses.refresh
    end

  end
end