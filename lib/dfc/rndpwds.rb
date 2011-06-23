require 'random/online'

module DFC
  # RndPwds helps create and validate passwords and passphrases.
  class RndPwds 

    attr_accessor :length, :chars, :words, :realrand, :timeout
    attr_accessor :min_username_length, :min_password_length, :min_effective_length
    def initialize( length = 256, filter = /[[:graph:]]/ )
      @length = length
      @chars = 0.upto(255).map{|ascii| ascii.chr}.select{|chr| chr=~filter}
      @words = nil  # '/usr/share/dict/words'
      @realrand = Random::RandomOrg.new
      @timeout = 15
      @min_username_length = 4
      @min_password_length = 4
      @min_effective_length = 7
    end

    # Note that if rand1 =~ rand or rand2 =~ rand, then (rand1(N) + rand2(N)) % N =~ rand.
    # So as long as either rand1 or rand2 is an honest rand, (rand1(N) + rand2(N)) % N is an honest rand.
    def passphrase?(length=@length)
      width = @chars.length
      Timeout::timeout(@timeout) do
        return @realrand.randnum(length, 0, width-1).inject(''){|string,randnum| string + @chars[ (randnum + rand(width)) % width ]}
      end
    end

    def passphrase!(length=@length)
      width = @chars.length
      length.times.inject(''){|string,ignored| string + @chars[ rand(width) ] }
    end

    def passphrase
      begin
        return passphrase?
      rescue Exception
        return passphrase!
      end
    end

    # Want to give user as much feed back as possible on salt problems
    def login_strength( username, password, return_on_error=false, &block)

      errors = 0
      message = ''

      error = Proc.new do |string|
        errors +=1
        message += string+"\n"
        return errors, message	if return_on_error
      end

      if password.nil?
        error.call("password not set")
      else
        error.call("password too short")		if password.length < @min_password_length
        error.call("password must have a digit")	if password !~ /\d/
        error.call("password must have a [A-Z]")	if password !~ /[A-Z]/
        error.call("password must have a [a-z]")	if password !~ /[a-z]/
        error.call("password must have a \\W")		if password !~ /\W/
      end

      salt = username.to_s+password.to_s
      error.call("can't have spaces")		if salt =~ /\s/
      error.call("no vowels used")		if salt !~ /[aeiou]/i
      error.call("no consonants used")		if salt !~ /[^aeiou\W\d]/i
      error.call("effectively too short")	if salt.chars.to_a.uniq.length < @min_effective_length

      if username.nil? then
        error.call("username not set")
      else
        if username.length < @min_username_length then
          error.call("username too short")	
        elsif @words then
          match = username.gsub(/\\/,'\\\\').gsub(/'/,"\\'").gsub(/\[/,'\\[').gsub(/\]/,'\\]')
          error.call("username taken") if `grep -i '#{match}' #{@words}`.length > 0
        end
      end

      # any other tests you want?
      if block then
       error.call("rejected") if !block.call(username,password)
      end

      return errors, message
    end

    def validate(username,password)
      errors, message = login_strength(username,password)
      raise message if errors > 0
    end

    def login(phrase=passphrase,&block)
      limit, u_offset, p_offset =
	phrase.length - @min_username_length - @min_password_length, @min_username_length - 1, @min_password_length - 1

      index = 0
      while index < limit do
        offset = index+@min_username_length
        username = phrase[index..(index+u_offset)]
        password = phrase[(offset)..(offset+p_offset)]
        errors, message = login_strength(username,password,true,&block)
        return username, password if errors < 1
        index += 1
      end

      return nil, nil # failed to get a suggestion
    end

  end
end
