class DeleteTableRecommendations < ActiveRecord::Migration[6.0]
  def change
    drop_table :recommendations
  end
end
