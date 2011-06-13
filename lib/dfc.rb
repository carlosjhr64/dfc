require 'dfc/configuration'
gem 'shredder', '~> 0.0'
require 'shredder'

module DFC

  def self.size_shreds(filename)
    size = File.size(filename)
    shreds = Math.log( size - 1 + Math::E ).to_i
    return size,shreds
  end

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

  def self.untouch(filename)
    Configuration::UNTOUCH.call(filename)
  end

  def self.rename( newfile, key )
    # If a collision occurs, it's a bug.
    # I'm writting this as if sha1sums don't collide.
    # Virtually never happens, but it's not impossible.
    raise "COLLISSION!!!" if DFC.exist?(key)
    filename = DFC.filename(key)
    File.rename(newfile, filename)
    DFC.untouch(filename)
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
    DFC.untouch(encrypted)
    # TODO passphrase written to disk :-??
    Configuration::FILE_CLEAR.call(intermidiary) if shred # ...in the interim.
    File.unlink( intermidiary )
  end

  def self.read_string( encrypted, salt, shred=true )
    tempfile = Tempfile.next
    DFC.decrypt( tempfile, encrypted, salt )
    DFC.untouch(encrypted)
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
    Configuration::PASSWORD_STRENGTH.call(username,password)
  end

  def self.digest(string)
    Configuration::STRING_DIGEST.call(string)
  end


  module Tempfile

    @@count = 0

    def self.next
      @@count += 1
      Configuration::TMP+"/scramble.#{$$}.#{@@count}"
    end

  end

  class Files < Array
    def initialize( length_or_array )
      is_array = length_or_array.kind_of?(Array) # is this an array?
      length = (is_array)? length_or_array.length : length_or_array # then what's the array length?
      super(length) # self made array of length
      0.upto(length-1){|index| self[index] = (is_array)? length_or_array[index] : Tempfile.next } # populate array
    end

    def unlink
      self.each{|tempfile| File.unlink(tempfile)}
    end

    def untouch # TODO untouch
      self.each{|filename| DFC.untouch(filename) }
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

    def get_resource_key(key)
      DFC.digest(key+@passphrase)
    end

    def exist?(key)
      DFC.exist?( get_resource_key(key) )
    end

    def get_resources(encrypted)
      index_decrypted = Tempfile.next
      DFC.decrypt(index_decrypted, encrypted, @passphrase)
      DFC.untouch(encrypted)
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

    def encrypt(filename, encrypted=Tempfile.next, force=true)
      DFC.encrypt(filename, encrypted, @passphrase, force)
      return encrypted
    end

    def decrypt(encrypted, filename=Tempfile.next, force=true)
      DFC.decrypt(filename, encrypted, @passphrase, force)
      return filename
    end

    def self.shred(intermediary,tempfiles,size)
      shredder = Shredder::Files.new(intermediary,tempfiles)
      begin
        # if it goes past size, there's a bug
        raise "unconfirmed file length" if shredder.shred(size+1) != size
      rescue Exception
        tempfiles.unlink
        raise $!
      ensure
        File.unlink(intermediary)
      end
    end

    def shred(filename)
      intermediary = encrypt(filename)
      size,length = DFC.size_shreds(intermediary)
      tempfiles = Files.new(length)
      Resources.shred(intermediary,tempfiles,size)
      return tempfiles
    end

    def create_shred_keys(tempfiles)
      shred_keys = []
      tempfiles.each do |path|
        fragment_key = get_resource_key( DFC.sha1sum(path) )
        shred_keys.push( fragment_key )
        DFC.rename( path, fragment_key )
      end
      return shred_keys
    end

    def save_shred_keys(shred_keys)
      index_file = Tempfile.next
      File.open(index_file,'w'){|index_handle| index_handle.puts shred_keys.join("\n") }
      index_encrypted = encrypt(index_file)
      Configuration::FILE_CLEAR.call(index_file)
      File.unlink(index_file)
      return index_encrypted
    end

    def insert(filename, key, force=false)
      raise "#{filename} does not exist." if !File.exist?(filename)
      index_key = get_resource_key(key)
      raise "#{key} exists." if !force && DFC.exist?(index_key)

      tempfiles = shred(filename)
      shred_keys = create_shred_keys(tempfiles)
      index_encrypted = save_shred_keys(shred_keys)

      delete_resources(index_key) # deletes previous entry
      DFC.rename( index_encrypted, index_key )
    end

    def self.sew(source_files)
      intermediary = Tempfile.next
      shredder = Shredder::Files.new(intermediary, source_files)
      begin
        shredder.sew
      rescue Exception
        File.unlink(intermediary)
        raise $!
      ensure
        source_files.untouch
      end
      return intermediary
    end

    def get_source_files(index_enc)
      Files.new( get_resources(index_enc).map{|rkey| DFC.find(rkey) } )
    end

    def extract(filename, key, force=false)
      raise "#{filename} exists." if !force && File.exist?(filename)
      index_enc = DFC.find( get_resource_key(key) )
      raise "#{key} not found" if index_enc.nil?

      source_files = get_source_files(index_enc)
      intermediary = Resources.sew(source_files)
      decrypt(intermediary, filename, force)
      File.unlink(intermediary)
    end

    def delete(key)
      raise "#{key} not found" if !delete_resources( get_resource_key(key) )
    end

  end

end
