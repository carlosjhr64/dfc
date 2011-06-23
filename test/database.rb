require 'dfc/database'

def assert(boolean)
  raise "Got one wrong" if !boolean
end

test = './test.txt'
outfile = './test.out'
File.unlink(outfile) if File.exist?(outfile)

database = DFC::Database.new( ['./tmp/A','./tmp/B','./tmp/C'], 'A passphrase for my database' )
string = 'test'
puts string

puts "Exist?"
if database.delete(string) then
  puts "Yes, deleted."
else
  puts "No"
end

puts "A"
database.ci(string,test)

puts "B"
database.co(string,outfile)
puts "C"
puts "diff #{test} #{outfile}"
raise "ci/co failed" if `diff #{test} #{outfile}`.strip.length != 0
puts database.verify

#what = 'What, what, what!?'
#database['login'] = what
#what_not = database['login']
#puts "Whatnot: #{what_not}"
#assert( what == what_not )
#puts "All tests passed! :)"
