class DailyWord < ApplicationRecord
  validates :word, presence: true, length: { is: 5 }
  validates :date, presence: true, uniqueness: true
  
  def self.current_word
    current_period = current_period_date
    daily_word = find_by(date: current_period)
    
    unless daily_word
      word = generate_word_for_period(current_period)
      daily_word = create!(word: word, date: current_period)
    end
    
    daily_word.word
  end
  
  def self.word_for_period(period_date)
    daily_word = find_by(date: period_date)
    return daily_word.word if daily_word
    
    word = generate_word_for_period(period_date)
    create!(word: word, date: period_date)
    word
  end
  
  def self.current_period_date
    now = Time.current
    period_hour = (now.hour / 10) * 10
    
    period_time = now.change(hour: period_hour, min: 0, sec: 0)
    period_time.to_date
  end
  
  def self.next_period_time
    now = Time.current
    current_period_hour = (now.hour / 10) * 10
    next_period_hour = current_period_hour + 10
    
    if next_period_hour >= 24
      (Date.current + 1).to_time.change(hour: 0, min: 0, sec: 0)
    else
      Date.current.to_time.change(hour: next_period_hour, min: 0, sec: 0)
    end
  end
  
  def self.time_until_next_period
    next_period_time - Time.current
  end
  
  private
  
  def self.generate_word_for_period(period_date)
    words = load_word_list
    seed = period_date.to_time.to_i / 36000
    words[Random.new(seed).rand(words.length)]
  end
  
  def self.load_word_list
    word_file_path = Rails.root.join('word.txt')
    if File.exist?(word_file_path)
      File.readlines(word_file_path).map(&:strip).reject(&:empty?)
    else
      default_words
    end
  end
  
  def self.default_words
    %w[kirpi araba sabun balık çadır deniz enlem fular geçit hakim
       ırmak irmik joker limon marul nasıl obruk nabız paket radyo
       zaman yaban kalem kitap masa duvar tavan zemin elma armut
       kiraz incir biber kabak pasta]
  end
end
