module DFC

  # Access to the directories
  # Meant to be subclassed.  All methods private or protected.
  class Access
    WORD = 0.upto(255).map{|i| i.chr}.select{|c| c=~/\w/ && c=~/[^_]/}

    attr_accessor :passphrase
    def initialize(directories,passphrase)
      @directories, @passphrase = directories, passphrase
      @sequence = Sequence.new
    end

    private

    def digest(string)
      key, l, r, y  =  '', WORD.length, 0, nil
      Digest::SHA1.digest(string+@passphrase).bytes.each do |b|
        y = b+r
        r = y/l
        key += WORD[y%l]
      end
      # going to ignore remainder
      return key
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
