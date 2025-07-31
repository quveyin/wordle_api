class CreateDailyWords < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_words do |t|
      t.string :word
      t.date :date

      t.timestamps
    end
    
    add_index :daily_words, :date, unique: true
  end
end
