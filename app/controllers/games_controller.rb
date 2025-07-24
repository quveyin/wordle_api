class GamesController < ApplicationController
  before_action :set_game, only: [:show, :guess]
  
  def new
    @game = Game.new
  end

  def create
    @game = Game.new
    @game.secret_word = generate_secret_word
    
    if @game.save
      redirect_to game_path(@game), notice: 'Yeni oyun başladı 5 harfli kelimeyi tahmin edin.'
    else
      render :new, alert: 'Oyun oluşturulamadı'
    end
  end

  def show
    @new_guess = Guess.new
    @guesses = @game.guesses.order(:created_at)
  end
  
  def guess
    return redirect_to @game, alert: 'Oyun bitti' if @game.completed?
    
    word = params[:word].to_s.downcase.strip
    
    # Kelime uzunluğu kontrolü
    if word.length != 5
      return redirect_to @game, alert: 'Sadece 5 harfli kelime giriniz.'
    end
    
    @new_guess = @game.guesses.build(word: word)
    
    if @new_guess.save
      if @game.won?
        redirect_to @game, notice: " Tebrikler kelimeyi #{@game.guesses.count} denemede buldunuz: #{@game.secret_word}"
      elsif @game.lost?
        redirect_to @game, alert: " Oyun bitti. Kelime: #{@game.secret_word}"
      else
        # Tahmin feedback'ini hesapla
        feedback = @new_guess.feedback
        correct_count = feedback.count('correct')
        present_count = feedback.count('present')
        
        if correct_count > 0 && present_count > 0
          message = " #{correct_count} doğru, #{present_count} yanlış yerde. Kalan: #{6 - @game.guesses.count}"
        elsif correct_count > 0
          message = " #{correct_count} harf doğru yerde. Kalan: #{6 - @game.guesses.count}"
        elsif present_count > 0
          message = " #{present_count} harf var ama yanlış yerde. Kalan: #{6 - @game.guesses.count}"
        else
          message = " Hiçbir harf eşleşmedi. Kalan: #{6 - @game.guesses.count}"
        end
        
        redirect_to @game, notice: message
      end
    else
      redirect_to @game, alert: 'Geçersiz tahmin. Lütfen geçerli bir kelime girin.'
    end
  end

  private
  
  def set_game
    @game = Game.find(params[:id])
  end

  def generate_secret_word
    words = [
      "kirpi", "araba", "sabun", "balık", "çadır", 
      "deniz", "enlem", "fular", "geçit", "hakim",
      "ırmak", "irmik", "joker", "limon", "marul", 
      "nasıl", "obruk", "nabız", "paket", "radyo",
      "zaman", "yaban", "kalem", "kitap", "masa",
      "duvar", "tavan", "zemin", "elma", "armut",
      "kiraz", "incir", "biber", "kabak", "pasta"
    ]
    words.sample
  end
end