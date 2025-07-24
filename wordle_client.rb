require 'net/http'
require 'json'
require 'uri'

class WordleClient
  BASE_URL = 'http://localhost:3000/api/v1'
  
  def initialize
    @game_id = nil
  end
  
  def start_game
    uri = URI("#{BASE_URL}/games")
    http = Net::HTTP.new(uri.host, uri.port)
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    
    response = http.request(request)
    
    if response.code == '201'
      data = JSON.parse(response.body)
      @game_id = data['id']
      puts "Yeni oyun başladı! (ID: #{@game_id})"
      puts data['message']
      puts "Kalan deneme: #{data['attempts_remaining']}"
      puts "-" * 50
      true
    else
      puts "Oyun başlatılamadı: #{response.body}"
      false
    end
  end
  
  def make_guess(word)
    return false unless @game_id
    
    uri = URI("#{BASE_URL}/games/#{@game_id}/guess")
    http = Net::HTTP.new(uri.host, uri.port)
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = { word: word }.to_json
    
    response = http.request(request)
    data = JSON.parse(response.body)
    
    if response.code == '200'
      display_guess_result(data)
      
      if data['status'] == 'won'
        puts "tebrikler #{data['message']}"
        return 'won'
      elsif data['status'] == 'lost'
        puts "oyun bitti #{data['message']}"
        return 'lost'
      else
        puts "Kalan deneme: #{data['attempts_remaining']}"
        return 'continue'
      end
    else
      puts "Hata: #{data['error'] || 'Bilinmeyen hata'}"
      false
    end
  end
  
  def get_game_status
    return unless @game_id
    
    uri = URI("#{BASE_URL}/games/#{@game_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    
    request = Net::HTTP::Get.new(uri)
    response = http.request(request)
    
    if response.code == '200'
      data = JSON.parse(response.body)
      puts "Oyun Durumu:"
      puts "Kalan deneme: #{data['attempts_remaining']}"
      puts "Durum: #{data['status']}"
      puts "Mesaj: #{data['message']}"
      
      if data['guesses'].any?
        puts "Tahminleriniz:"
        data['guesses'].each_with_index do |guess, index|
          print "#{index + 1}. #{guess['word'].upcase}: "
          display_feedback(guess['feedback'])
        end
      end
    end
  end
  
  private
  
  def display_guess_result(data)
    print "#{data['word'].upcase}: "
    display_feedback(data['feedback'])
  end
  
  def display_feedback(feedback)
    feedback.each do |status|
      case status
      when 'correct'
        print "G"
      when 'present'
        print "Y"
      else
        print "X"
      end
    end
    puts
  end
end

def main
  puts "Wordle"
  puts "=" * 50
  
  client = WordleClient.new
  
  unless client.start_game
    puts "Sunucu çalışıyor mu? (rails server)"
    exit 1
  end
  
  loop do
    print "\n5 harfli Türkçe kelime girin (veya 'q' çıkış, 's' durum): "
    input = gets.chomp.downcase
    
    case input
    when 'quit', 'q', 'exit'
      puts "Görüşürüz! 👋"
      break
    when 'status', 's'
      client.get_game_status
    when ''
      puts "Lütfen bir kelime girin."
    else
      if input.length != 5
        puts "Sadece 5 harfli kelime giriniz!"
        next
      end
      
      result = client.make_guess(input)
      
      if result == 'won' || result == 'lost'
        print "\nYeni oyun başlatmak ister misiniz? (y/n): "
        answer = gets.chomp.downcase
        if answer == 'y' || answer == 'yes' || answer == 'evet'
          client = WordleClient.new
          client.start_game
        else
          break
        end
      end
    end
  end
end