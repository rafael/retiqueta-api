class CreateBankAccount < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.references :profile, index: true, foreign_key: true, null: false
      t.string :document_type, limit: 20, null: false
      t.string :document_id, limit: 50, null: false
      t.string :owner_name, limit: 50, null: false
      t.string :bank_name, limit: 50, null: false
      t.string :account_type, limit:  20, null: false
      t.string :account_number, limit: 60, null: false
      t.string :country, limit: 20, null: false, default: 'venezuela'
      t.timestamps null: false
    end
  end
end
