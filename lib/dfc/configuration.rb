module DFC
# Configuration provides some default values
module Configuration
  # WARNING: changing these on pre-existing data may cause incompatibilities.

  ### Files and directories ###


  HIDDEN = ENV[:HOME]+'/.dfc2'
  TMP = HIDDEN+'/tmp'

  DIRECTORIES = [
	HIDDEN+'/A', #'/red',
	HIDDEN+'/B', #'/green',
	HIDDEN+'/C', #'/blue',
    ]

  WORDS = '/usr/share/dict/words'


  #### Binaries and their options ###


  FILE_CLEARER = 'shred'

  FILE_CRIPTOR = 'gpg -q --batch --passphrase-fd 0'
  ENCRIPTING = '--force-mdc --symmetric'
  DECRIPTING = '--decrypt'

  FILE_DIGESTOR = 'sha1sum'


  ### Procedures ###


  UNTOUCH = Proc.new{|filename| File.utime( 0, 0, filename ) }
  TOUCH = Proc.new{|filename| File.utime( now=Time.now.to_i, now, filename ) }

  FILE_CLEAR = Proc.new{|filename| system( "#{FILE_CLEARER} #{filename}" ) }

  require 'digest/sha1'
  STRING_DIGEST = Proc.new{|string| Digest::SHA1.hexdigest(string) }
  FILE_DIGEST = Proc.new{|filename| `#{FILE_DIGESTOR} #{filename}`.strip.split(/\s+/).first }

  STRING_ENCRIPT = Proc.new{ raise "STRING_ENCRIPT not defined. TODO" } # TODO
  STRING_DECRIPT = Proc.new{ raise "STRING_DECRIPT not defined. TODO" } # TODO

  FILE_ENCRYPT = Proc.new{|plain,encrypted,passphrase,force|
    yes = (force)? '--yes': ''
    IO.popen( "#{FILE_CRIPTOR} #{yes} --output '#{encrypted}' #{ENCRIPTING} '#{plain}'", 'w' ){|pipe| pipe.puts passphrase; pipe.flush }
  }
  FILE_DECRYPT = Proc.new{|plain,encrypted,passphrase,force|
    yes = (force)? '--yes': ''
    IO.popen( "#{FILE_CRIPTOR} #{yes} --output '#{plain}' #{DECRIPTING} '#{encrypted}'", 'w' ){|pipe| pipe.puts passphrase; pipe.flush }
  }

  PASSWORD_STRENGTH = Proc.new{|username,password|
      raise "username not set"			if username.nil?
      raise "password not set"			if password.nil?
      raise "username too short"		if username.length < 4
      raise "password too short"		if password.length < 4
      raise "password must have a \\d"		if password !~ /\d/
      raise "password must have a [A-Z]"	if password !~ /[A-Z]/
      raise "password must have a [a-z]"	if password !~ /[a-z]/
      raise "password must have a \\W"		if password !~ /[a-z]/
      raise "username taken" if `grep -i #{username} #{WORDS}`.length > 0
  }


end
end
