class AddPasswordResetFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_reset_token, :string, limit: 128
    add_column :users, :password_reset_sent_at, :datetime
    add_index :users, :password_reset_token, unique: true
  end
end
