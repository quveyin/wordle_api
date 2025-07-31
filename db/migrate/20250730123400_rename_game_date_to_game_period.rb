class RenameGameDateToGamePeriod < ActiveRecord::Migration[7.1]
  def change
    rename_column :games, :game_date, :game_period
  end
end
