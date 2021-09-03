class DeleteTableRecommendations < ActiveRecord::Migration[6.0]
  def change
    drop_table :recommendations, force: :cascade
  end
end
