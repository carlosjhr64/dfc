gem 'symmetric_gpg', '~> 1.0'
require 'symmetric_gpg'
require 'dfc/access'

module DFC
  class Database < Access
    def initialize(passphrase,directories)
      @gpg = SymmetricGPG::IOs.new(passphrase)
      super(directories)
    end

    def ci(key,filename,force=false)
      File.open(filename,'r') do |reader|
        @gpg.plain = reader
        self.writer(key,force) do |writer|
          @gpg.encrypted = writer
          @gpg.encrypt
        end
      end
    end

    def co(key,filename,force=false)
      raise "File exists." if !force && File.exist?(filename)
      self.reader(key) do |reader|
        @gpg.encrypted = reader
        File.open(filename,'wb') do |writer|
          @gpg.plain = writer
          @gpg.decrypt
        end
      end
    end
  end
end
