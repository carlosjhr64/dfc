require 'dfc/buffer'

def assert(boolean)
  raise "got one wrong" if !boolean
end

buffer = DFC::Buffer.new
buffer.putc 'a'
buffer.putc 'b'
buffer.putc 'c'
assert( buffer.buffer[0..2] == 'abc' )

string = ''
thread = Thread.new do
  string += buffer.getc
  string += buffer.getc
  string += buffer.getc
  string += buffer.getc
end
sleep(1)
assert thread.alive?
assert string == 'abc'
buffer.putc 'd'
sleep(1)
assert !thread.alive?
assert string == 'abcd'

puts "OK!"
