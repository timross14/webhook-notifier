class CreateWebhookEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :webhook_events do |t|
      t.integer :webhook_id, null: false
      t.string :status
      t.string :response
      t.timestamps
    end
  end
end
