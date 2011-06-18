require 'digest'
require 'dfc/database'

def assert(boolean)
  raise "Got one wrong" if !boolean
end

readme = './README.txt'
outfile = './README.out'
File.unlink(outfile) if File.exist?(outfile)

database = DFC::Database.new( ['./tmp/A','./tmp/B','./tmp/C'], 'A passphrase for my database' )
key = 'README'
puts key

puts "Exist?"
if database.exist?(key) then
  puts "Yes.. then delete"
  database.delete(key)
  puts "OK?"
end
database.ci(key,readme)

database.co(key,outfile)

raise "ci/co failed" if `diff #{readme} #{outfile}`.strip.length != 0

what = 'What, what, what!?'
database['login'] = what
what_not = database['login']
assert( what == what_not )

puts "All tests passed! :)"
