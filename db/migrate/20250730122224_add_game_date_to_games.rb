class AddGameDateToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :game_date, :date
  end
end
