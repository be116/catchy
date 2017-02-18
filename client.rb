require "socket"

dest = "localhost"
port = 8888

if (ARGV.length != 1)
  dest = ARGV[0]
  puts dest
  exit
end

s = TCPSocket.open(dest, port)

def nicecatch(ball=nil, grove)
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

ball = nil

while true

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
    puts "lack of %d chars" % (diff.abs + 1)
  end
  s.puts myball

  puts "--enemy turn--"
  command = s.gets.gsub(/(\r\n|\r|\n)/, "")
  #p command, "miss"
  if command == "miss"
    win
    s.close
    exit
  end

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
end
