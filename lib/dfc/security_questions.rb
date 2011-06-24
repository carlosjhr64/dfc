module DFC

  module SecurityQuestions

    QUESTIONS = [
	"What is your favorite word?  ",
	"What school did you attend for sixth grade?  ",
	"What are the last 4 digits of your Social Security number?  ",
	"What is your middle name?  ",
	"What is the name of your first pet?  ",
	"In what city where you born?  ",
	"When is your birthdate (yyyy-mm-dd)?  ",
	"What is your mother's maiden name?  ",
	"What is the first name of your biggest crush?  ",
	"What is the first name of your first crush?  ",
	"Which was your favorite childhood movie?  ",
	"Which was your favorite teen movie?  ",
	"What is the name of your favorite childhood friend?  ",
	"What was your favorite band or singer in junior high?  ",
    ]

    INSTRUCTIONS = <<EOT
Answer these security questions any way you like (with gibberish even), but
you need to be able to replicate your answers.
Your answers are not stored, they're (strip-ed and) used to feed into Digest::SHA256.
IF YOU FORGET HOW YOU ANSWERED ANY OF THESE QUESTIONS YOU'LL LOOSE YOUR DATA!
The first question will be "What is you favorite word?"
This one is the most likely one you'll fail to replicate later, so think about it.
Your first answer will not be shown, but
the rest will be visible so beware of evesdroppers.

Press enter where ready.
EOT

    AGAIN = <<EOT
To verify, re-enter your answer.
EOT

    INSTRUCTIONS2 = <<EOT
Now replicate your anwers.
If you're unable to do so, you'll need to start over.
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
      digest = Digest::SHA256.new
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
        digest << answer
        system('clear')
      end
      return digest.hexdigest
    end

    def self.hash
      system('clear')
      puts INSTRUCTIONS
      $stdin.gets

      hexdigest0 = SecurityQuestions.ask_questions

      system('clear')
      puts INSTRUCTIONS2
      $stdin.gets

      hexdigest1 = SecurityQuestions.ask_questions

      if !(hexdigest0 == hexdigest1) then
        system('clear')
        puts FAIL_MESSAGE
        exit
      end

      return hexdigest0
    end

  end

end
