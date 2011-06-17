module DFC

  class Sequence
    def initialize
      @sequence = 0
    end

    def succ
      @sequence += 1
    end

    SEQUENCE = Sequence.new
  end

end
