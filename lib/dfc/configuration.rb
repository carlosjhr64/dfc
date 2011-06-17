module DFC
# Configuration provides some default values
module Configuration

  ### Files and directories ###

  HIDDEN = ENV[:HOME]+'/.dfc2'
  TMP = HIDDEN+'/tmp'

  DIRECTORIES = [
	HIDDEN+'/A', #'/red',
	HIDDEN+'/B', #'/green',
	HIDDEN+'/C', #'/blue',
    ]

  #### Binaries and their options ###

  FILE_CLEARER = 'shred'

  FILE_DIGESTOR = 'sha1sum'

  ### Procedures ###

  UNTOUCH = Proc.new{|filename| File.utime( 0, 0, filename ) }
  TOUCH = Proc.new{|filename| File.utime( now=Time.now.to_i, now, filename ) }

  FILE_CLEAR = Proc.new{|filename| system( "#{FILE_CLEARER} #{filename}" ) }
end
end
