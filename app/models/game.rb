class Game < ApplicationRecord
  belongs_to :user, optional: true
  has_many :guesses, dependent: :destroy
  
  validates :secret_word, presence: true, length: { is: 5 }
  validates :token, uniqueness: true, allow_nil: true
  validates :game_period, presence: true, on: :update
  
  before_create :set_defaults
  before_create :generate_token
  before_create :set_game_period
  
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
  
  def generate_token
    loop do
      self.token = SecureRandom.urlsafe_base64(8)
      break unless Game.exists?(token: self.token)
    end
  end
  
  def set_game_period
    self.game_period = DailyWord.current_period_date
  end
  
  def self.current_word
    DailyWord.current_word
  end
end