class CreateFulfillments < ActiveRecord::Migration
  def change
    create_table :fulfillments do |t|
      t.string :uuid, null: false
      t.string :order_id, null: false
      t.string :state, null: false
      t.timestamps null: false
    end

    add_index :fulfillments, :order_id
  end
end
