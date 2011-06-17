require 'dfc/sequence'

module DFC

  class Tempfile

    def initialize(directory)
      @directory = directory
      @base = Sequence::SEQUENCE.succ
      @sequence = Sequence.new
    end

    def succ
      File.join(Configuration::TMP,"#{$$}.#{@base}.#{@sequence.succ}")
    end

  end

end
