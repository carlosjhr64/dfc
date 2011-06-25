gem 'ruby-password', '~> 0.15'

autoload :Digest, 'digest'
autoload :Timeout, 'timeout'
autoload :Password, 'password' # ruby-password

module DFC
  VERSION = '0.0.0'

  # This application's hidden directory for the user
  HIDDEN = File.join( ENV[:HOME], '.dfc2' )
  DARK = 'dark'
  DEPOSITORY = 'depository'
  YING = 'ying'
  YANG = 'yang'
  
  def self.dark
    [ File.join(HIDDEN,DARK,YING), File.join(HIDDEN,DARK,YANG) ]
  end

  def self.depository
    [ File.join(HIDDEN,DEPOSITORY,YING), File.join(HIDDEN,DEPOSITORY,YANG) ]
  end

  autoload :Sequence, 'dfc/sequence'
  autoload :SecurityQuestions, 'dfc/security_questions'
  autoload :Install, 'dfc/install'
  autoload :Database, 'dfc/database'
  autoload :Access, 'dfc/access'
end
