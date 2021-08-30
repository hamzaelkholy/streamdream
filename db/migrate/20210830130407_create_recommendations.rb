class CreateRecommendations < ActiveRecord::Migration[6.0]
  def change
    create_table :recommendations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :streaming_service, null: false, foreign_key: true

      t.timestamps
    end
  end
end
