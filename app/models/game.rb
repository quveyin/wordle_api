class Game < ApplicationRecord
  belongs_to :user, optional: true
  has_many :guesses, dependent: :destroy
  
  validates :secret_word, presence: true, length: { is: 5 }
  
  before_create :set_defaults
  
  def completed?
    guesses.count >= 6 || won?
  end
  
  def won?
    guesses.any? { |guess| guess.word.downcase == secret_word.downcase }
  end
  
  def lost?
    guesses.count >= 6 && !won?
  end
  
  def remaining_attempts
    6 - guesses.count
  end

  private

  def set_defaults
    self.attempts_count ||= 0
  end
end