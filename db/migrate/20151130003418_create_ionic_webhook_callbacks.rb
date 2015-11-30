class CreateIonicWebhookCallbacks < ActiveRecord::Migration
  def change
    create_table :ionic_webhook_callbacks do |t|
      t.text :payload
      t.timestamps null: false
    end
  end
end
