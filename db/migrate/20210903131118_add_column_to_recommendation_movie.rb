class AddColumnToRecommendationMovie < ActiveRecord::Migration[6.0]
  def change
    add_column :recommendation_movies, :network, :string
  end
end
