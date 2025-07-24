module WordleDictionary
  WORDS = ["kirpi","araba", "sabun", "balık", "çadır", "deniz", "enlem", "fular", "geçit", "hakim", 
           "ırmak", "irmik", "joker", "limon", "marul", "nasıl", "obruk", "nabız", "paket", "radyo", 
           "zaman", "yaban"].freeze

  def self.sample_word
    WORDS.sample
  end
end