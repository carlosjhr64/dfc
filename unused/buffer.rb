module DFC
# A buffer to connect io's
class Buffer
  def initialize
    @buffer = 256.times.inject(''){|string,ignored| string+' '}
    @read = @write = 0
    @write_close = @read_close = false # start out open
  end

  def buffer
    @buffer
  end

  def open_read
    @read = 0
    @read_close = false
    true
  end

  def open_write
    @write = 0
    @write_close = false
    true
  end

  def open
    open_write
    open_read
    true
  end

  def close_read
    @read_close = true
  end

  def close_write
    @write_close = true
  end

  def close
    close_write
    while !(@read == @write) do
      # wait for the reader
      Thread.pass
    end
    close_read
  end

  def putc( c )
    raise "write closed" if @write_close
    @buffer[@write] = c.chr
    write = (@write + 1) % buffer.length
    while write == @read do
      # We've caught up to read, wait for it to move forward.
      Thread.pass
    end
    @write = write
  end

  def  getc
    raise "read closed" if @read_close

    while @read == @write do
      # We've caught up to write!
      # If write is closed, we're done.
      return nil if @write_close
      # Else wait/pass for write.
      Thread.pass
    end
    read = @read
    @read = (@read + 1) % buffer.length

    buffer[read]
  end

  def getbyte
    (c = getc)? c.ord : nil
  end

end
end
