gem 'ruby-password', '~> 0.15'

autoload :Digest, 'digest'
autoload :Timeout, 'timeout'
autoload :Password, 'password' # ruby-password

module DFC
  VERSION = '0.0.0'
  # This application's hidden directory for the user
  HIDDEN = File.join( ENV[:HOME], '.dfc2' )
  # The dark databsae
  DIRECTORIES = [
    File.join(HIDDEN,'A'),
    File.join(HIDDEN,'B'),
    File.join(HIDDEN,'C'),
  ]

  autoload :Tempfile, 'dfc/tempfile'
  autoload :Sequence, 'dfc/sequence'
  autoload :SecurityQuestions, 'dfc/security_questions'
  autoload :RndPwds, 'dfc/rndpwds'
  autoload :Install, 'dfc/install'
  autoload :Database, 'dfc/database'
end
