require 'digest'
gem 'symmetric_gpg', '~> 2.0'
require 'symmetric_gpg'
require 'dfc/access'

module DFC
  class Database < Access
    STRING_PATTERN = Regexp.new('[^\.][^.\d]$')

    def self.number_of_shreds(size)
      Math.log( (size - 1).to_f + Math::E ).to_i
    end

    def initialize(directories, passphrase)
      super(directories,passphrase)
      @gpg = SymmetricGPG::Shreds.new(passphrase)
      def @gpg.verify

         sha = Digest::SHA1.new
         File.open(@plain,'r') do |filehandle|
           while c = filehandle.getc do
             sha.update(c)
           end
         end
         hexdigest1 = sha.hexdigest

         sha = Digest::SHA1.new
         _dec do |stdout| 
           while c = stdout.getc do
             sha.update(c)
           end
         end
         hexdigest0 = sha.hexdigest

         hexdigest0 == hexdigest1
      end
    end

    protected

    def passphrase=(passphrase)
      super
      @gpg.passphrase = passphrase
    end

    public

    def validate(string)
      raise "Not a valid string key" if !(string =~ STRING_PATTERN)
    end

    def find_shreds(string)
      validate(string)

      shreds = []
      count = 0
      shred = string + ".#{count}"
      while filename = find(shred) do
        shreds.push(filename)
        count += 1
        shred = string + ".#{count}"
      end

      return (count>0)? shreds : nil
    end

    def get_shreds(string, number)
      validate(string)
  
      shreds = []
      number.times{|count| shreds.push(filesucc( string + ".#{count}" )) }

      return shreds
    end

    # This verifies the last action or the given key-string/filename.
    def verify(string=nil,filename=nil)
      filename = @gpg.plain if filename.nil?
      raise "File does not exist!" if !File.exist?(filename)

      shreds = (string.nil?)?  @gpg.encrypted : find_shreds(string)
      raise "Key does not exist!" if shreds.nil?

      @gpg.encrypted = shreds
      @gpg.plain = filename
      @gpg.verify
    end

    def delete(string)
      if shreds = find_shreds(string) then
        shreds.each{|shred| File.unlink(shred)}
        return true
      end
      return false
    end

    def [](string)
      if shreds = find_shreds(string) then
        @gpg.encrypted = shreds
        @gpg.force = true # has no effect, but... called for by symmetry.
        return @gpg.sew # string version
      end
      return nil
    end

    def []=(string,value)
      if shreds = find_shreds(string) then
        shreds.each{|shred| File.unlink(shred)}
      end
      number = Database.number_of_shreds( string.length )
      @gpg.encrypted = get_shreds( string, number )
      @gpg.plain  = value
      @gpg.force = true
      @gpg.shred # string version
    end

    def ci(string,filename,force=false)
      raise "File does not exists!" if !File.exist?(filename)
      if shreds = find_shreds(string) then
        raise "Key exists!" unless force
        shreds.each{|shred| File.unlink(shred)}
      end
      number = Database.number_of_shreds( File.size(filename) )
      shreds = get_shreds(string, number)
      @gpg.encrypted = shreds
      @gpg.plain = filename
      @gpg.force = force
      @gpg.encrypt # file version
      raise "Checkin failed" unless verify
    end

    def co(string,filename,force=false)
      raise "File exists!" if !force && File.exist?(filename)
      if shreds = find_shreds(string) then
        @gpg.encrypted = shreds
        @gpg.plain = filename
        @gpg.force = force
        @gpg.decrypt # file version
        raise "Checkout failed" unless verify
      else
        raise "Key does not exist!"
      end
    end

  end
end
