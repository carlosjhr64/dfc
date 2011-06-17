require 'dfc/authentication'

def assert(boolean)
  raise "nope!" if !boolean
end

include DFC

#if false then

assert( Authentication::MIN_USERNAME_LENGTH == 4 )
assert( Authentication::MIN_PASSWORD_LENGTH == 4 )
assert( Authentication::MIN_EFFECTIVE_LENGTH == 7 )
assert( Authentication::PASSPHRASE_CHARS.length == 93 )
assert( Authentication::PASSPHRASE_LENGTH == 256 )

assert( Authentication::REALRAND.class == Random::RandomOrg )

assert( File.exist?( Authentication::WORDS ) )

bang = nil
begin
  Authentication.new('not_access')
rescue Exception
  bang = $!.message
end
assert( bang == "need DFC::Access" )

# TODO real access
# Authentication.new()
# TODO auth?

passphrase = Authentication.realrand
assert( passphrase.class == String )
assert( passphrase.length == Authentication::PASSPHRASE_LENGTH )
puts
puts "Inpect RealRand passphrase.  Does it look OK?"
puts passphrase

passphrase = Authentication.pseudorand
assert( passphrase.class == String )
assert( passphrase.length == Authentication::PASSPHRASE_LENGTH )
puts
puts "Inpect Pseudo passphrase.  Does it look OK?"
puts passphrase

passphrase = Authentication.new_passphrase
assert( passphrase.class == String )
assert( passphrase.length == Authentication::PASSPHRASE_LENGTH )
puts
puts "Inpect *Public method* passphrase.  Does it look OK?"
puts passphrase

puts

#end

error = false
begin
  salt = Authentication.password_strength( nil, nil )
rescue Exception
  assert($!.message == "2 errors")
  error = true
end
assert(error)

error = false
begin
  salt = Authentication.password_strength( '', '' )
rescue Exception
  assert($!.message == "9 errors")
  error = true
end
assert(error)


gu = 'Tocv'
gp = 'G7$a'
[
	['Taken',gp],
	[gu,'GQ$a'],
	[gu,'G7$P'],
	[gu,'G79a'],
	['Tzcv','G7$p'],
	['AUEI','E7$i'],
	['aGcv',gp],
	[gu,'G7 $a'],
].each do |username,password|
  puts [username,password].join(' / ')
  error = false
  begin
    salt = Authentication.password_strength( username, password )
  rescue Exception
    assert($!.message == "1 errors")
    error = true
  end
  assert(error)
end

# TODO register
# TODO self.get_passphrase
# TODO authenticate

puts "All test passed!"
