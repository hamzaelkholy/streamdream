class CreateStreamingServices < ActiveRecord::Migration[6.0]
  def change
    create_table :streaming_services do |t|
      t.string :name

      t.timestamps
    end
  end
end
