class CreateSale < ActiveRecord::Migration
  def change
    create_table :sales do |t|
      t.string :uuid, null: false
      t.string :user_id, null: false
      t.string :order_id, null: false
      t.float :amount, null: false
      t.float :store_fee, null: false
      t.timestamps null: false
    end

    add_index :sales, :user_id
    add_index :sales, [:user_id, :uuid]
  end
end
