class AddUserToGames < ActiveRecord::Migration[7.1]
  def change
    add_reference :games, :user, foreign_key: true
    Game.reset_column_information
    first_user = User.first_or_create!(email: 'default@example.com', password: 'password')
    Game.update_all(user_id: first_user.id)
    change_column_null :games, :user_id, false
  end
end