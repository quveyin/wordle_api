class AddSecretWordAndAttemptsCountToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :attempts_count, :integer unless column_exists?(:games, :attempts_count)
    
    add_column :games, :secret_word, :string unless column_exists?(:games, :secret_word)
  end
end