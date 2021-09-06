class AddTableRecommendations < ActiveRecord::Migration[6.0]
  def change
    create_table :recommendations do |t|
      t.references :user
      t.references :streaming_service
    end
  end
end
