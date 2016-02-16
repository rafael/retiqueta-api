class Order < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :uuid, null: false
      t.string :shipping_address, null: false
      t.string :payment_transaction_id, null: false
      t.string :total_price, :float, null: false
      t.string :user_id, null: false
      t.string :financial_status, null: false
      t.string :currency, null: false
      t.timestamps null: false
    end
    add_index :orders, [:user_id, :uuid]
    add_index :orders, :user_id
  end
end
