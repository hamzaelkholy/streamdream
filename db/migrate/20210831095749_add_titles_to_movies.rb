class AddTitlesToMovies < ActiveRecord::Migration[6.0]
  def change
    add_column :movies, :title, :string
  end
end
