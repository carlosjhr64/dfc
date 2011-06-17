require 'digest'
require 'timeout'
require 'random/online'
require 'symmetric_gpg'
require 'dfc/access'

module DFC
  # Authentication's job is to give the passphrase only to it's owner.
  # It does this by requiring the owner to give the secret salt (username+password).
  class Authentication

    MIN_USERNAME_LENGTH = 4
    MIN_PASSWORD_LENGTH = 4
    MIN_EFFECTIVE_LENGTH = 7

    PASSPHRASE_CHARS	= "\t !\#$%&()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_abcdefghijklmnopqrstuvwxyz{|}~".chars.to_a
    PASSPHRASE_LENGTH	= 256

    REALRAND = Random::RandomOrg.new
  
    WORDS = '/usr/share/dict/words'

    def initialize(access)
      @access = access
      @passphrase = nil
    end

    def auth?
      !@passphrase.nil?
    end

    # Note that if rand1 =~ rand or rand2 =~ rand, then (rand1(N) + rand2(N)) % N =~ rand.
    # So as long as either rand1 or rand2 is an honest rand, (rand1(N) + rand2(N)) % N is an honest rand.
    def self.realrand
      chars = PASSPHRASE_CHARS.length
      REALRAND.randnum(PASSPHRASE_LENGTH, 0, chars-1).map{|randnum| PASSPHRASE_CHARS[ (randnum + rand(chars)) % chars ] }.join
    end

    def self.pseudorand
       chars = PASSPHRASE_CHARS.length
      PASSPHRASE_LENGTH.times.map{ PASSPHRASE_CHARS[ rand(chars) ] }.join
    end

    def self.new_passphrase
      begin
        Timeout::timeout(5.0) do
          return Authentication.realrand
        end
      rescue Exception
        $stderr.puts $!
        return Authentication.pseudorand
      end
    end

    # Want to give user as much feed back as possible salt problems
    def self.password_strength(username,password)
      errors = 0
      message = ''
      error = Proc.new{|string| errors +=1; message += string }

      if username.nil? then
        error.call("username not set")
      else
        if username.length < MIN_USERNAME_LENGTH then
          error.call("username too short")	
        else
          error.call("username taken") if `grep -i #{username} #{WORDS}`.length > 0
        end
      end

      if password.nil?
        error.call("password not set")
      else
        error.call("password too short")		if password.length < MIN_PASSWORD_LENGTH
        error.call("password must have a digit")	if password !~ /\d/
        error.call("password must have a [A-Z]")	if password !~ /[A-Z]/
        error.call("password must have a [a-z]")	if password !~ /[a-z]/
        error.call("password must have a \\W")		if password !~ /\W/
      end

      salt = username+password
      error.call("can't have spaces")		if salt =~ /\s/
      error.call("no vowels used")		if salt !~ /[aeiou]/i
      error.call("no consonants used")		if salt !~ /[^aeiou\W\d]/i
      error.call("effectively too short")	if salt.chars.to_a.uniq.length < MIN_EFFECTIVE_LENGTH

      return salt, errors, message
    end

    def self.salt(username,password)
      salt, errors, message = Authenticate.password_strength(username,password)
      raise message if errors > 0
      return salt
    end

    def register(username,password)
      salt = Authenticate.salt(username,password)
      login = Digest::SHA1.hexdigest(salt)
      sleep(1) # prevent mining

      passphrase = Authenticate.passphrase
      raise "login exist" if @database.exist?( login )
      @database[login] = passphrase


      raise "login exists" if @access.exist?(login) # TODO Mutex?
      @passphrase = Authenticate.passphrase
      encripted = SymetricGPG.new(salt).encstr(@passphrase)
      @access.writer(login){|writer| writer.print encripted }
    end

    def authenticate(username,password)
      salt = Authenticate.password_strength(username,password)
      login = Digest::SHA1.hexdigest(salt)
      sleep(1) # prevent mining
      raise "Not registered" if !@access.exist?(login)
      stringio = StringIO.new
      @access.reader(key){|reader| SymmetricGPG.new(salt).e2pp(reader,stringio) }
      @passsphrase = stringio.string
    end
  end

end
