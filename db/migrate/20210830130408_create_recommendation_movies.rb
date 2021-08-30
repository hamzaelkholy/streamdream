class CreateRecommendationMovies < ActiveRecord::Migration[6.0]
  def change
    create_table :recommendation_movies do |t|
      t.references :recommendation, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true

      t.timestamps
    end
  end
end
