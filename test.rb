a = true
b = false

def swap()
  buf = $a
  $a = $b
  $b = buf
end

swap
#swap
#swap
#swap

puts a
puts b