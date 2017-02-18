require "socket"

port = 8888

server = TCPServer.open(port)

ball = nil

def nicecatch(ball=nil, grove)
  #p ball, grove, ball==nil, ball==grove
  if ball == nil
    return true
  end
  if ball == grove
  	return true
  end
  return false
end

def lose()
  puts "LOSE..."
end

def win()
  puts "WIN!!!"
end

s = server.accept

while true
  puts "--enemy turn--"
  command = s.gets.gsub(/(\r\n|\r|\n)/, "")
  if command == "miss"
  	win
  	s.close
  	exit
  end

  #puts "command : %s" % command

  ball = s.gets.gsub(/(\r\n|\r|\n)/, "")
  puts "type->%s" % ball
  puts "retype?"
  grove = STDIN.gets.gsub(/(\r\n|\r|\n)/, "")
  if !nicecatch(ball, grove)
  	s.puts "miss"
    s.close
  	lose
  	exit
  end

  puts "<NICE>"

  puts "--my turn--"
  s.puts "throw"
  puts "type?"
  myball = ""
  while true
    myball = STDIN.gets.gsub(/(\r\n|\r|\n)/, "")
    if ball==nil
      break
    end
    diff = myball.size - ball.size
    if diff > 0
      break
    end
    puts "lack of %d chars" % (diff + 1)
  end
  s.puts myball

end