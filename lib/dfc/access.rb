require 'digest'
require 'dfc/sequence'

module DFC

  # Access to the directories
  # Meant to be subclassed.  All methods private or protected.
  class Access

    attr_accessor :passphrase
    def initialize(directories,passphrase)
      @directories, @passphrase = directories, passphrase
      @sequence = Sequence.new
    end

    private

    def digest(string)
      Digest::SHA1.hexdigest(string+@passphrase)
    end

    protected

    def filesucc(string)
      key = digest(string)
      File.join( @directories[ @sequence.succ % @directories.length ], key )
    end

    def find(string)
      key = digest(string)
      @directories.each do |directory|
        filename = File.join(directory,key)
        if File.exist?(filename) then
          return filename
        end
      end
      return nil
    end

  end

end
