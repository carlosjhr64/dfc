module DFC
# Configuration provides some default values
module Configuration

  ### Files and directories ###

  # This application's hidden directory for the user
  HIDDEN = File.join( ENV['HOME'], '.dfc2' )

  # The dark databsae
  DIRECTORIES = [
	File.join(HIDDEN,'A'),
	File.join(HIDDEN,'B'),
	File.join(HIDDEN,'C'),
    ]

  # Just a package for all of the above
  PARAMETERS = [HIDDEN,DIRECTORIES]
end
end
