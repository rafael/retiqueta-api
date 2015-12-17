class CreatePushTokens < ActiveRecord::Migration
  def change
    create_table :push_tokens do |t|
      t.string :user_id, null: false, limit: 160
      t.string :uuid, null: false, limit: 160
      t.string :platform, null: false, limit: 30
      t.string :token, null: false, limit: 160
      t.string :device_id, limit: 160
      t.string :environment, null: false, limit: 30
      t.timestamps null: false
    end
    add_index :push_tokens, :user_id
    add_index :push_tokens, [:user_id, :platform]
  end
end
