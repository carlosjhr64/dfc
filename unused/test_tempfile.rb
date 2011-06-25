#!/usr/bin/evn ruby
require 'dfc'

def assert(boolean, msg='')
  raise "Bad #{msg}" if !boolean
end

include DFC

tempfile = Tempfile.new('./tmp')
path = tempfile.succ
assert( path == "./tmp/#{$$}.1.1", path)
path = tempfile.succ
assert( path == "./tmp/#{$$}.1.2", path)

tempfile = Tempfile.new('./tmp')
path = tempfile.succ
assert( path == "./tmp/#{$$}.2.1", path)
path = tempfile.succ
assert( path == "./tmp/#{$$}.2.2", path)
path = tempfile.succ
assert( path == "./tmp/#{$$}.2.3", path)

puts "tempfile: All test passed!"
