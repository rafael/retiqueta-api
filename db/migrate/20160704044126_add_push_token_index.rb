class AddPushTokenIndex < ActiveRecord::Migration
  def change
    add_index :push_tokens, [:token, :platform], unique: true
  end
end
