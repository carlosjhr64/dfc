module DFC
  module Install
    def self.ynask(prompt)
      print "#{prompt} (Y/n)? "
      char = $stdin.gets.strip
      char == 'Y'
    end

    def self.proceed_with_install?
      system('clear')
      print <<EOT
The hidden directory for dfc, #{HIDDEN}, needs to be created.
It will contain user specific data.
To complete the install, you'll be asked some security questions that will take a few minutes to complete.
EOT
      Install.ynask('Proceed?')
    end

    def self.get_password
      system('clear')
      puts <<EOT
A passphrase based on your answers to your security questions has been created.
This passphrase will be used to encrypt your data.
In order to safeguard this passphrase, you'll be asked for a password.
The "strength" of the password will be checked, but it's up to you to make it random.
If you forget your password, you'll have to go through the security questions again.
Press [Enter] to continue.
EOT
      $stdin.gets
      system('clear')
      password = nil
      while password.nil? do
        begin
          password = Password.get( "New password: " )
          password.check
          verify = Password.get( "Again: " )
          raise "did not match" if !(password == verify)
        rescue StandardError
          puts "Bad password, #{$!}.  Try again."
          password = nil
        end
      end
      system('clear')
      return password
    end

    def self.install
      raise "#{HIDDEN} exists" if File.exist?(HIDDEN)
      exit unless Install.proceed_with_install?
      passphrase = SecurityQuestions.hash
      password = Install.get_password
      Dir.mkdir(HIDDEN,0700)
      [ File.join(HIDDEN,DARK), File.join(HIDDEN,DEPOSITORY) ].each do |subdir|
        Dir.mkdir(subdir,0700)
        [ File.join(subdir,YING), File.join(subdir,YANG) ].each do |subdir|
          Dir.mkdir(subdir,0700)
        end
      end
      database = DFC::Database.new(DFC.dark,password)
      database['passphrase'] = passphrase
    end

    def self.proceed_with_reset?
      system('clear')
      puts <<EOT
You can get your depository passphrase back by answering your security questions exactly as you did before.
There is no check for validity... gpg will just fail to decrypt if you get the wrong passphrase.
But without your old password you won't be able to decrypt the data you chose to keep dark.
If there is no chance of getting the old password back, then there is no reason to keep the dark files.

You'll be asked if you want to delete your dark files.
And after that you'll go through your security questions.
Enter 'Y' to continue, anything else to quit.
EOT
      Install.ynask('Proceed?')
    end

    def self.delete_dark?
      system('clear')
      if Install.ynask('Do you want to delete the dark files?') then
        return Install.ynask('Are your sure?')
      end
      false
    end

    def self.delete_dark!
      puts "OK, deleting dark files..."
      DFC.dark.each do |directory|
        Find.find(directory) do |filename|
          File.unlink(filename) if File.file?(filename)
        end
      end
      puts "Dark files deleted.  Press [Enter] to continue."
      $stdin.gets
    end

    def self.reset
      raise "#{HIDDEN} does not exists" if !File.exist?(HIDDEN) # just a quick goof check
      exit unless Install.proceed_with_reset?
      Install.delete_dark! if Install.delete_dark?
      passphrase = SecurityQuestions.hash
      password = Install.get_password
      database = DFC::Database.new(DFC.dark,password)
      database['passphrase'] = passphrase
    end
  end
end
