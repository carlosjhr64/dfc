module DFC
  # unique names for temporary files.
  class Tempfile

    def initialize(directory)
      @directory = directory
      @base = Sequence::SEQUENCE.succ
      @sequence = Sequence.new
    end

    def succ
      File.join(@directory,"#{$$}.#{@base}.#{@sequence.succ}")
    end

  end

end
