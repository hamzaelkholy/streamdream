class UpdateMovieColumn < ActiveRecord::Migration[6.0]
  def change
    change_column :movies, :date_released, :string
  end
end
