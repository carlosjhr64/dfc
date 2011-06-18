require 'dfc/authenticated'

def assert(boolean)
  raise "got an error" if !boolean
end

adb = DFC::Authenticated.new( ['./tmp/A','./tmp/B','./tmp/C'] )

assert( adb.authenticated? == false )

begin
  adb.register('Malaka','Ez2rmr!')
rescue Exception
  puts $!
  adb.authenticate('Malaka','Ez2rmr!')
end

puts "OK"
