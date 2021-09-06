class AddWatchmodeIdToMovies < ActiveRecord::Migration[6.0]
  def change
    add_column :movies, :watchmode_id, :string
  end
end
