class CreateGuesses < ActiveRecord::Migration[7.1]
  def change
    create_table :guesses do |t|
      t.string :word
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
