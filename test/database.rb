require 'digest'
require 'dfc/database'

def assert(boolean)
  raise "Got one wrong" if !boolean
end

readme = './README.txt'
outfile = './README.out'

database = DFC::Database.new('A passphrase for my database', ['./tmp/A','./tmp/B','./tmp/C'] )
error = false
begin
  database.ci('README',readme)
rescue StandardError
  puts $!
  error = ($!.message == 'Not a valid key.')
end
assert(error)

File.unlink(outfile) if File.exist?(outfile)

error = false
begin
  database.co('README',outfile)
rescue StandardError
  puts $!
  error = ($!.message == 'Key not found.')
end
assert(error)

key = Digest::SHA1.hexdigest('README')
puts key

database.delete(key) if database.exist?(key)
database.ci(key,readme)

database.co(key,outfile)

raise "ci/co failed" if `diff #{readme} #{outfile}`.strip.length != 0
puts "All tests passed! :)"
