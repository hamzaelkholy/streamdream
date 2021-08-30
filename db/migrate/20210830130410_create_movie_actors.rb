class CreateMovieActors < ActiveRecord::Migration[6.0]
  def change
    create_table :movie_actors do |t|
      t.boolean :leading_actor
      t.references :actor, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true

      t.timestamps
    end
  end
end
