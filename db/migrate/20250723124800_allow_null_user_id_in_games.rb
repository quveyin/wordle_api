class AllowNullUserIdInGames < ActiveRecord::Migration[7.1]
  def change
    change_column_null :games, :user_id, true
  end
end