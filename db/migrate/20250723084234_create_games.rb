class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.string :secret_word
      t.integer :attempts_count

      t.timestamps
    end
  end
end
