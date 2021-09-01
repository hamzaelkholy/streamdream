class AddColumnToMovie < ActiveRecord::Migration[6.0]
  def change
    add_column :movies, :imdb_id, :string
    add_column :movies, :poster_url, :string
  end
end
