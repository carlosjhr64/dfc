require 'dfc/rndpwds'
require 'dfc/database'

module DFC
  # Authentication's job is to give the passphrase only to it's owner.
  # It does this by requiring the owner to give the secret salt (username+password).
  class Authenticated < Database

    def initialize(directories)
      super
      @rndpwd = RndPwds.new
    end

    protected if !$test

    def get_login(username,password)
      sleep(1) # prevent mining
      @rndpwd.validate(username,password) # raises error on weak login
      # and one more demand...
      raise "not a key pattern" if username !~ self.key_pattern
      return password+username
    end

    public

    def authenticated?
      !self.passphrase.nil?
    end

    def register(username,password)
      login = get_login(username,password)
      # going to save the passphrase in login using login as the passphrase.
      self.passphrase = login
      raise "login exist" if self.exist?( login )
      # create a new passphrase
      passphrase = @rndpwd.passphrase
      self[login] = passphrase
      # then set the database passphrase
      self.passphrase = passphrase
      # if we got here, we're good.
    end

    def authenticate(username,password)
      login = get_login(username,password)
      # going to read the passphrase stored in login using login as the passphrase.
      self.passphrase = login
      raise "not registered" if !self.exist?(login)
      passphrase = self[login]
      self.passphrase = passphrase
      # if we got here, we're good.
    end
  end

end
