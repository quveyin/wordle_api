class Guess < ApplicationRecord
  belongs_to :game
  
  validates :word, presence: true, length: { is: 5 }
  
  def check_against_secret(secret_word)
    result = []
    word_chars = word.downcase.chars
    secret_chars = secret_word.downcase.chars
    
    word_chars.each_with_index do |char, index|
      if secret_chars[index] == char
        result << 'correct'
      elsif secret_chars.include?(char)
        result << 'present'
      else
        result << 'absent'
      end
    end
    
    result
  end
  
  def feedback
    check_against_secret(game.secret_word)
  end
end
