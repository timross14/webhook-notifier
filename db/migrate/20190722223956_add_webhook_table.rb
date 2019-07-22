class AddWebhookTable < ActiveRecord::Migration[5.2]
  def change
    create_table :webhooks do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.string :zip_code, null: false
      t.timestamps
    end
  end
end
