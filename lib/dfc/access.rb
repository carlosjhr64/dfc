require 'dfc/sequence'

module DFC

  # Access to the directories
  # Meant to be subclassed.  All methods private or protected.
  class Access
    KEY_PATTERN = Regexp.new('^[0123456789abcdef]{40}$')

    def initialize(directories)
      @directories = directories
      @sequence = Sequence.new
    end

    private

    def filesucc(key)
      raise "Not a valid key." if !(key=~KEY_PATTERN)
      File.join( @directories[ @sequence.succ % @directories.length ], key )
    end

    def find!(key)
      @directories.each do |directory|
        filename = File.join(directory,key)
        return filename if File.exist?(filename)
      end
      return nil
    end

    def find(key)
      if filename = find!(key) then
        return filename
      end
      raise "Key not found."
    end

    def exist!(key)
      raise "COLLISSION!!!" if find!(key)
    end

    protected

    def insert( infile, key )
      exist!(key)
      filename = filesucc(key)
      File.rename(infile, filename)
      true
    end

    def extract( key, outfile )
      filename = find(key)
      File.rename( filename, outfile )
      true
    end

    def writer(key,force=false)
      exist!(key) if !force
      filename = filesucc(key)
      if block_given? then
        File.open(filename,'wb'){|writer| yield(writer)}
      else
        return File.open(filename,'wb')
      end
      true
    end

    def reader(key)
      filename = find(key)
      if block_given? then
        File.open(filename,'r'){|reader| yield(reader)}
      else
        return File.open(filename,'r')
      end
      true
    end

    def exist?(key)
      (find!(key).nil?)? false: true
    end

    def delete(key)
      filename = find(key)
      File.unlink(filename)
      true
    end

  end

end
