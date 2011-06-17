gem 'symmetric_gpg', '~> 1.0'
require 'symmetric_gpg'
require 'dfc/access'

module DFC

  class Database < Access
    KEY_PATTERN = Regexp.new('[^\.][^.\d]$')

    def initialize(passphrase,directories)
      @passphrase = passphrase
      @gpg = SymmetricGPG::IOs.new(passphrase)
      super(directories)
    end

    def digest(key)
      raise "Not a valid key." if !(key=~KEY_PATTERN)
      Digest::SHA1.hexdigest(key+@passphrase)
    end

    def delete(key)
      resource_key = digest(key)
      super(resource_key)
    end

    def exist?(key)
      resource_key = digest(key)
      super(resource_key)
    end

    def ci(key,filename,force=false)
      resource_key = digest(key)
      File.open(filename,'r') do |reader|
        @gpg.plain = reader
        self.writer(resource_key,force) do |writer|
          @gpg.encrypted = writer
          @gpg.encrypt
        end
      end
    end

    def co(key,filename,force=false)
      raise "File exists." if !force && File.exist?(filename)
      resource_key = digest(key)
      self.reader(resource_key) do |reader|
        @gpg.encrypted = reader
        File.open(filename,'wb') do |writer|
          @gpg.plain = writer
          @gpg.decrypt
        end
      end
    end
  end
end
