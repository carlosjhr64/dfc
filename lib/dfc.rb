require 'dfc/configuration'

module DFC

  @@sequence = 0

  def self.directories
    Configuration::DIRECTORIES
  end

  def self.filename( key )
    @@sequence += 1
    dir = DFC.directories
    "#{dir[ @@sequence % dir.length ]}/#{key}"
  end

  def self.find(key)
    DFC.directories.each do |directory|
      filename = "#{directory}/#{key}"
      return filename if File.exist?(filename)
    end
    return nil
  end

  def self.exist?(key)
    (DFC.find(key).nil?)? false: true
  end

  def self.epoched(filename)
    File.utime( 0, 0, filename )
  end

  def self.rename( newfile, key )
    # If a collision occurs, it's a bug.
    # I'm writting this as if sha1sums don't collide.
    # Virtually never happens, but it's not impossible.
    raise "COLLISSION!!!" if DFC.exist?(key)
    filename = DFC.filename(key)
    File.rename(newfile, filename)
    DFC.epoched(filename)
  end

  def self.encrypt(plain,encrypted,passphrase,force=false)
    raise "Plain file #{plain} does not exist" if !File.exist?(plain)
    Configuration::FILE_ENCRYPT.call(plain,encrypted,passphrase,force)
    raise "Encripted #{encrypted} not created" if !File.exist?(encrypted)
  end

  def self.decrypt(plain,encrypted,passphrase,force=false)
    raise "Encripted #{encrypted} does not exist" if !File.exist?(encrypted)
    Configuration::FILE_DECRYPT.call(plain,encrypted,passphrase,force)
    raise "Plain file #{plain} not created" if !File.exist?(plain)
  end

  def self.sha1sum(filename)
    Configuration::FILE_DIGEST.call(filename)
  end

  def self.login_exist?(login)
    sleep(1) # to avoid login mining
    DFC.exist?(login)
  end

  def self.write_string( passphrase, encrypted, salt, shred=true )
    intermidiary = Tempfile.next
    File.open( intermidiary, 'w' ){|fh| fh.write passphrase }
    DFC.encrypt( intermidiary, encrypted, salt )
    DFC.epoched(encrypted)
    # TODO passphrase written to disk :-??
    Configuration::FILE_CLEAR.call(intermidiary) if shred # ...in the interim.
    File.unlink( intermidiary )
  end

  def self.read_string( encrypted, salt, shred=true )
    tempfile = Tempfile.next
    DFC.decrypt( tempfile, encrypted, salt )
    DFC.epoched(encrypted)
    passphrase = File.read(tempfile)
    # TODO decrypted passphrase written to disk :-??
    Configuration::FILE_CLEAR.call(tempfile) if shred # ...in the interim.
    File.unlink(tempfile)
    return passphrase
  end

  def self.register(login,salt,passphrase='')
    raise "Username exists" if DFC.login_exist?(login)
    while passphrase.length < 64 do
      passphrase = (256).times.map{ rand(256).chr }.select{|char| (char=~/[[:graph:]]/) && (char=~/[^'"]/) }.inject(''){|string,char| string+char}
    end
    DFC.write_string( passphrase, DFC.filename(login), salt )

    passphrase
  end

  def self.get_passphrase(login,salt,newuser)
    if newuser then
      # returns passphrase
      return DFC.register(login,salt)
    else
      encrypted = DFC.find(login)
      raise "Bad Login" if encrypted.nil?
      # returns passphrase
      return DFC.read_string( encrypted, salt )
    end
    raise "TOTAL FAIL! :))"
  end

  def self.unregister(login)
    DFC.directories.each do |dir|
      filename = "#{dir}/#{login}"
      File.unlink(filename) if File.exist?(filename)
    end
  end

  def self.password_strength(username,password)
      raise "username not set"			if username.nil?
      raise "password not set"			if password.nil?
      raise "username too short"		if username.length < 4
      raise "password too short"		if password.length < 4
      raise "password must have a \\d"		if password !~ /\d/
      raise "password must have a [A-Z]"	if password !~ /[A-Z]/
      raise "password must have a [a-z]"	if password !~ /[a-z]/
      raise "password must have a \\W"		if password !~ /[a-z]/
      raise "username taken" if `grep -i #{username} #{Configuration::WORDS}`.length > 0
  end

  def self.digest(string)
    Configuration::STRING_DIGEST.call(string)
  end

  class ReopenFile
    attr_reader :path
    attr_reader :handle
    def initialize(path)
      @path = path
      @handle = nil
    end

    def open(mode='r')
      @handle = File.open(@path,mode)
    end

    def close
      @handle.close
      @handle = nil
    end

    def unlink
      File.unlink(@path)
    end
  end

  class Tempfile < ReopenFile

    @@count = 0

    def self.next
      @@count += 1
      Configuration::TMP+"/scramble.#{$$}.#{@@count}"
    end

    def initialize
      super(Tempfile.next)
    end
  end

  class FilesArray < Array
    def initialize(length)
      super
    end

    def open(mode='r')
      0.upto(self.length-1){|index| self[index].open(mode) }
    end

    def close
      0.upto(self.length-1){|index| self[index].close }
    end

    def unlink
      0.upto(self.length-1){|index| self[index].unlink }
    end
  end

  class Tempfiles < FilesArray
    def initialize(length)
      super
      0.upto(length-1){|index| self[index] = Tempfile.new }
    end
  end

  class SourceFiles < FilesArray
    def initialize(sources)
      length = sources.length
      super(length)
      0.upto(length-1){|index| self[index] = ReopenFile.new( DFC.find(sources[index]) ) }
    end

    def epoched
      0.upto(self.length-1){|index| DFC.epoched( self[index].path ) }
    end
  end

  class Resources

    def initialize( username, password, newuser=false )
      DFC.password_strength(username,password)
      salt = username+password
      login = DFC.digest(salt)
      @passphrase = DFC.get_passphrase(login,salt,newuser)
      @login = login
    end

    def change_authentication(username, password)
      DFC.password_strength(username,password)
      salt = username+password
      login = DFC.digest(salt)
      DFC.register(login,salt,@passphrase)
      DFC.unregister(@login)
      @login = login
    end

    def resource_key(key)
      DFC.digest(key+@passphrase)
    end

    def exist?(key)
      DFC.exist?( resource_key(key) )
    end

    def get_resources(encrypted)
      index_decrypted = Tempfile.next
      DFC.decrypt(index_decrypted, encrypted, @passphrase)
      DFC.epoched(encrypted)
      resources = []
      File.open(index_decrypted){|index_handle| index_handle.each{|line| resources.push(line.strip) }}
      Configuration::FILE_CLEAR.call(index_decrypted)
      File.unlink(index_decrypted)
      return resources
    end

    def delete_resources(index_key)
      if filename = DFC.find(index_key) then
        resources = get_resources(filename)
        File.unlink(filename)
        resources.pop
        resources.each do |resource_key|
          if resource_file = DFC.find(resource_key) then
            File.unlink(resource_file)
          end
        end
        return true
      end
      return false
    end

    def insert(filename, key, force=false)
      raise "#{filename} does not exist." if !File.exist?(filename)
      index_key = resource_key(key)
      raise "#{key} exists." if !force && DFC.exist?(index_key)

      intermediary = Tempfile.next
      DFC.encrypt(filename,intermediary,@passphrase)

      size = File.size(intermediary)
      length = Math.log( size - 1 + Math::E ).to_i

      tempfiles = Tempfiles.new(length)

      count = 0
      File.open(intermediary,'r') do |filehandle|
        xor = 0
        tempfiles.open('w')
        filehandle.each_byte do |chr|
          break if !(count < size)
          tempfiles[ count % length ].handle.putc (chr^xor)
          xor = chr
          count += 1
        end
        tempfiles.close
      end
      File.unlink(intermediary)

      if !(count == size) then
        tempfiles.unlink
        raise "There is a bug!  Unconfirmed file length (#{count} != #{size})."
      end

      fragment_keys = []
      tempfiles.each do |tempfile|
        path = tempfile.path
        fragment_key = resource_key( DFC.sha1sum(path) )
        fragment_keys.push( fragment_key )
        DFC.rename( path, fragment_key )
      end
      fragment_keys.push( count.to_s )

      index_file = Tempfile.next
      File.open(index_file,'w'){|index_handle| index_handle.puts fragment_keys.join("\n") }
      index_encrypted = Tempfile.next
      DFC.encrypt(index_file,index_encrypted,@passphrase)
      Configuration::FILE_CLEAR.call(index_file)
      File.unlink(index_file)

      delete_resources(index_key) # deletes previous entry
      DFC.rename( index_encrypted, index_key )
    end


    def extract(filename, key, force=false)
      raise "#{filename} exists." if !force && File.exist?(filename)
      index_key = resource_key(key)
      index_enc = DFC.find(index_key)
      raise "#{key} not found" if index_enc.nil?

      resources = get_resources(index_enc)
      count = resources.pop.to_i
      source_files = SourceFiles.new(resources)
      length = resources.length

      xor = 0
      intermediary = Tempfile.next # 2 b intermidary
      File.open(intermediary,'w') do |filehandle|
        source_files.open
        0.upto(count-1) do |index|
          chr = (source_files[ index % length ].handle.getbyte ^ xor)
          xor = chr
          filehandle.putc chr.chr
        end
        source_files.close
      end
      source_files.epoched
      DFC.decrypt(filename,intermediary,@passphrase,force)
      File.unlink(intermediary)
    end

    def delete(key)
      raise "#{key} not found" if !delete_resources( resource_key(key) )
    end

  end

end
