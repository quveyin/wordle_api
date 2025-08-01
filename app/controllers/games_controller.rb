class GamesController < ApplicationController
  before_action :set_game, only: [:show, :guess]
  
  def new
    @game = Game.new
  end

  def create
    current_period = DailyWord.current_period_date
    existing_game = current_session_current_period_game
    
    if existing_game
      redirect_to game_token_path(existing_game.token)
      return
    end
    
    @game = Game.new(secret_word: Game.current_word)
    
    if @game.save
      session[:game_ids] ||= []
      session[:game_ids] << @game.id
      
      redirect_to game_token_path(@game.token)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @game = Game.find_by!(token: params[:token])
    
    unless session[:game_ids]&.include?(@game.id)
      redirect_to root_path, alert: "Bu oyuna erişim yetkiniz yok."
      return
    end
    
    @guesses = @game.guesses.order(:created_at)
  end
  
  def stats
    stats = default_stats.merge(get_stats_cookie)
    render json: stats
  end
  
  def guess
    return redirect_to game_token_path(@game.token), alert: 'Oyun bitti' if @game.completed?
    
    word = params[:word].to_s.downcase.strip
    
    if word.length != 5
      return redirect_to game_token_path(@game.token), alert: 'Sadece 5 harfli kelime giriniz.'
    end
    
    unless valid_word?(word)
      return redirect_to game_token_path(@game.token), alert: "'#{word}' geçersiz kelime. Lütfen geçerli bir Türkçe kelime giriniz."
    end
    
    @new_guess = @game.guesses.build(word: word)
    
    if @new_guess.save
      if @game.won? || @game.lost?
        update_game_stats(@game.won?, @game.guesses.count)
      end
      
      if @game.won?
        redirect_to game_token_path(@game.token), notice: " Tebrikler kelimeyi #{@game.guesses.count} denemede buldunuz: #{@game.secret_word}"
      elsif @game.lost?
        redirect_to game_token_path(@game.token), alert: " Oyun bitti. Kelime: #{@game.secret_word}"
      else
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
        
        redirect_to game_token_path(@game.token), notice: message
      end
    else
      redirect_to game_token_path(@game.token), alert: 'Geçersiz tahmin. Lütfen geçerli bir kelime girin.'
    end
  end

  private
  
  def set_game
    @game = Game.find_by!(token: params[:token])
  end

  def current_session_current_period_game
    return nil unless session[:game_ids]
    
    current_period = DailyWord.current_period_date
    session_ids = session[:game_ids]
    
    Game.where(id: session_ids, game_period: current_period).first
  end
  
  def load_valid_words
    @@valid_words ||= begin
      word_file_path = Rails.root.join('word.txt')
      if File.exist?(word_file_path)
        File.readlines(word_file_path).map(&:strip).reject(&:empty?).to_set
      else
        [
          "kirpi", "araba", "sabun", "balık", "çadır", 
          "deniz", "enlem", "fular", "geçit", "hakim",
          "ırmak", "irmik", "joker", "limon", "marul", 
          "nasıl", "obruk", "nabız", "paket", "radyo",
          "zaman", "yaban", "kalem", "kitap", "masa",
          "duvar", "tavan", "zemin", "elma", "armut",
          "kiraz", "incir", "biber", "kabak", "pasta"
        ].to_set
      end
    end
  end
  
  def valid_word?(word)
    normalized_word = normalize_turkish_chars(word.downcase.strip)
    load_valid_words.any? { |valid_word| normalize_turkish_chars(valid_word) == normalized_word }
  end
  
  def normalize_turkish_chars(text)
    text.tr('ıİ', 'ii').downcase
  end
  
  def default_stats
    {
      'games_played' => 0,
      'games_won' => 0,
      'current_streak' => 0,
      'max_streak' => 0,
      'guess_distribution' => {
        '1' => 0, '2' => 0, '3' => 0, '4' => 0, '5' => 0, '6' => 0
      }
    }
  end

  def get_stats_cookie
    JSON.parse(cookies['wordle_stats'] || '{}')
  rescue JSON::ParserError
    {}
  end

  def set_stats_cookie(stats)
    cookies['wordle_stats'] = {
      value: stats.to_json,
      expires: 1.year.from_now,
      httponly: true
    }
  end
  
  def update_game_stats(won, guess_count)
    stats = default_stats.merge(get_stats_cookie)
    stats['games_played'] += 1
    
    if won
      stats['games_won'] += 1
      stats['current_streak'] += 1
      stats['max_streak'] = [stats['max_streak'], stats['current_streak']].max
      
      guess_count_str = guess_count.to_s
      stats['guess_distribution'][guess_count_str] += 1
    else
      stats['current_streak'] = 0
    end
    
    set_stats_cookie(stats)
  end
end