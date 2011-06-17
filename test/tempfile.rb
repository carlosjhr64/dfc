#!/usr/bin/evn ruby
require 'dfc/tempfile'
require 'dfc/configuration'

def assert(boolean)
  raise "nope" if !boolean
end

include DFC

tempfile = Tempfile.new(Configuration::TMP)

path = tempfile.succ
assert( path =~ /\/\d+\.1\.1$/ )

path = tempfile.succ
assert( path =~ /\/\d+\.1\.2$/ )

puts "tempfile: All test passed!"
