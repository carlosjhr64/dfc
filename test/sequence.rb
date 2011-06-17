#!/usr/bin/env ruby
require 'dfc/sequence'

def assert( boolean )
  raise "nope" if !boolean
end

include DFC

assert( Sequence::SEQUENCE.succ == 1 )
assert( Sequence::SEQUENCE.succ == 2 )
assert( Sequence::SEQUENCE.succ == 3 )

seq = Sequence.new
assert( seq.succ == 1 )
assert( seq.succ == 2 )
assert( seq.succ == 3 )

puts "sequence: all test passed"
