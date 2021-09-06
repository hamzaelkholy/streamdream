class AddTableRecommendations < ActiveRecord::Migration[6.0]
  def change
    create_table :recommendations do |t|
      t.references :users,
      t.references :streaming_services
    end
  end
end
