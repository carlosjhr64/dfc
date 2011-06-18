require 'dfc/rndpwds'

def assert(boolean)
  raise "Missed one" if !boolean
end

rndpwds = DFC::RndPwds.new
assert( rndpwds.length == 256 )

username,password = rndpwds.login{|username,password| username=~/[^.][^.\d]$/ }
puts
puts "Got something reasonable?"
puts "Suggest: #{username} #{password}"
puts

puts "Testing the 3 passphrase methods:"

puts
puts "passphrase? <= online version"
passphrase0 = rndpwds.passphrase?
puts passphrase0
assert( passphrase0.length == 256 )

puts
puts "passphrase! <= rand version"
passphrase1 = rndpwds.passphrase!
puts passphrase1
assert( passphrase1.length == 256 )

puts
puts "passphrase <= begin/rescue version"
passphrase2 = rndpwds.passphrase
puts passphrase2
assert( passphrase2.length == 256 )

puts
puts "All test passed"
