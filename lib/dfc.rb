gem 'ruby-password', '= 0.15.5'
gem 'symmetric_gpg', '~> 2.0'

autoload :Digest, 'digest'
autoload :Timeout, 'timeout'
autoload :Find, 'find'
autoload :Password, 'password' # ruby-password
autoload :SymmetricGPG, 'symmetric_gpg'

module DFC
  VERSION = '2.0.1'

  WORD = 0.upto(255).map{|i| i.chr}.select{|c| c=~/\w/ && c=~/[^_]/}
  QGRAPH = 0.upto(255).map{|i| i.chr}.select{|c| c=~/[[:graph:]]/ && c=~/[^`'"]/}

  def self.bitable2string(bitable,cset)
    string, l, r, y  =  '', cset.length, 0, nil
    bitable.bytes.each do |b|
      y = b+r
      r = y/l
      string += cset[y%l]
    end
    # going to ignore remainder
    return string
  end

  def self.qgraphed(bitable)
    DFC.bitable2string(bitable,QGRAPH)
  end

  def self.worded(bitable)
    DFC.bitable2string(bitable,WORD)
  end

  # This application's hidden directory for the user
  HIDDEN = File.join( ENV['HOME'], '.dfc' )
  DARK = 'dark'
  DEPOSITORY = 'depository'
  YIN = 'yin'
  YANG = 'yang'
  
  def self.dark
    [ File.join(HIDDEN,DARK,YIN), File.join(HIDDEN,DARK,YANG) ]
  end

  def self.depository
    [ File.join(HIDDEN,DEPOSITORY,YIN), File.join(HIDDEN,DEPOSITORY,YANG) ]
  end

  autoload :Sequence, 'dfc/sequence'
  autoload :SecurityQuestions, 'dfc/security_questions'
  autoload :Install, 'dfc/install'
  autoload :Database, 'dfc/database'
  autoload :Access, 'dfc/access'
end
