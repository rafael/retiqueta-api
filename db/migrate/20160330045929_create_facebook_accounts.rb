class CreateFacebookAccounts < ActiveRecord::Migration
  def change
    create_table :facebook_accounts do |t|
      t.string :user_id
      t.string :token
      t.integer :expires_in
      t.string :uuid
      t.timestamps null: false
    end

    add_index :facebook_accounts, :uuid, unique: true
    add_index :facebook_accounts, :user_id
  end
end
