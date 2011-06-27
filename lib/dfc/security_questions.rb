module DFC

  module SecurityQuestions
    QGRAPH = 0.upto(255).map{|i| i.chr}.select{|c| c=~/[[:graph:]]/ && c=~/[^`'"]/}

    QUESTIONS = [

	# Not definite?

	"Your favorite word:  ",
	"A short memorable quote from one of your friends:  ",
	"Name of a real jerk:  ",

	# Good (?)

	"A book you read in high school:  ",

	# Vulnerable to family

	"A TV show your parents watched:  ",
	"Your maternal grandmother's maiden name:  ", # maybe even researchable
	"Your first pet's name:  ",
	"Destination of the first long road trip you remember taking:  ", # probably family, maybe vulnerable to friends
	"The name of the first cat you've known: ",

	# Vulnerable to friends

	"The most ridiculous nickname among your friends:  ",
	"Your high school friend's favorite rock-band:  ",
	"Name of your best friend in primary school:  ",
	"Name of the person you had your first romantic moment:  ",
	"First movie you walked out of or really hated:  ", # but still pretty good

	# Searchable space

	"The color year make model of the oldest car you remember your parents owning:  ",

	# Guessable from research

	"First city you remember being in that is not your place of birth:  ",

	# Researchable

	"Middle name of your nearest relative:  ",
	"Last four digits of a number that does not change (ie. SS#):  ",
	"Your fifth grade school:  ",
	"Title of your first job:  ",
    ]

    INSTRUCTIONS = <<EOT
Answer these security questions any way you like, but
you need to be able to replicate your answers.
You should try to give a different answer for each question.
Your answers are not stored, they're used to feed into Digest::SHA512 to create a passphrase.
IF YOU FORGET HOW YOU ANSWERED ANY OF THESE QUESTIONS YOU'LL LOOSE YOUR DATA!
So it's not about giving the right answer, it's about getting the right passphrase.
The questions are phrased *Family Feud* style.
The first question will be "Your favorite word:"
This one is the most likely one you'll fail to replicate later, so think about it.
Your first answer will not be shown, but
the rest will be visible so beware of evesdroppers.

Press [Enter] where ready.
EOT

    AGAIN = <<EOT
To verify, re-enter your answer.
EOT

    INSTRUCTIONS2 = <<EOT
Now replicate your anwers.
If you're unable to do so, you'll need to start over.
Pres [Enter] to continue.
EOT

    FAIL_MESSAGE = <<EOT
Sorry, you failed to replicate a question.
You'll need to start over.
EOT

    def self.first_question(question)
      answer = Password.get(question).to_s
      puts AGAIN
      verify = Password.get(question).to_s
      if !(answer == verify) then
        puts FAIL_MESSAGE
        exit
      end
      return answer
    end

    def self.ask_questions
      sha512 = Digest::SHA512.new
      system('clear')
      first = true
      QUESTIONS.each do |question|
        answer = nil
        if first then
          first = false
          answer = SecurityQuestions.first_question(question)
        else
          print question
          answer = $stdin.gets.strip
        end
        sha512 << answer
        system('clear')
      end
      string, l, r, y  =  '', QGRAPH.length, 0, nil
      sha512.digest.bytes.each do |b|
        y = b+r
        r = y/l
        string += QGRAPH[y%l]
      end
      # going to ignore remainder
      return string
    end

    def self.hash
      system('clear')
      puts INSTRUCTIONS
      $stdin.gets

      passphrase = SecurityQuestions.ask_questions

      system('clear')
      puts INSTRUCTIONS2
      $stdin.gets

      verify = SecurityQuestions.ask_questions

      if !(passphrase == verify) then
        system('clear')
        puts FAIL_MESSAGE
        exit
      end

      return passphrase
    end

  end

end
