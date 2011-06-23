
[ ['ruby-password', '~> 0.15'],
  ['realrand', '~> 1.0'],
].each do |name,version|
  begin
    # Not absolutely required...
    gem name, version
  rescue Exception
    # never mind.
  end
end


autoload :Digest, 'digest'
autoload :Timeout, 'timeout'
autoload :Password, 'password' # ruby-password
module DFC
  autoload :Tempfile, 'dfc/tempfile'
  autoload :Sequence, 'dfc/sequence'
  autoload :SecurityQuestions, 'dfc/security_questions'
  autoload :RndPwds, 'dfc/rndpwds'
end
