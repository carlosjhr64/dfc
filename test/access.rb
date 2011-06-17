#!/usr/bin/env ruby
require 'dfc/access'
require 'dfc/configuration'
require 'digest'

def assert( boolean )
  raise 'nope' if !boolean
end

include DFC

access = Access.new( Configuration::DIRECTORIES )

key = Digest::SHA1.hexdigest('Hello World')
puts "Verify that it looks reasonably"
puts access.filesucc(key)
puts access.filesucc(key)
puts access.filesucc(key)
error = false
begin
  k = key.chop
  puts access.filesucc(k)
rescue Exception
  error = true
end
assert(error)

error = false
begin
  k = key.chop
  k = k+'X'
  puts access.filesucc(k)
rescue Exception
  error = true
end
assert(error)

assert( access.exist?(key) == false)
filename = access.filesucc(key)

begin
  `touch #{filename}`
  assert( access.exist?(key) == true)
rescue Exception
  puts $!
  puts $!.backtrace
  raise $!
ensure
  File.unlink(filename) if File.exist?(filename)
end


begin
  assert( access.exist?(key) == false)
  `touch temp`
  filename = access.insert( 'temp', key )
  assert( access.exist?(key) == true)
rescue Exception
  puts $!
  puts $!.backtrace
  raise $!
ensure
  File.unlink(filename) if File.exist?(filename)
end

puts "All tests passed"
