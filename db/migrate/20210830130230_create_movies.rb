class CreateMovies < ActiveRecord::Migration[6.0]
  def change
    create_table :movies do |t|
      t.string :genre
      t.date :date_released
      t.string :director
      t.text :description
      t.integer :rating

      t.timestamps
    end
  end
end
