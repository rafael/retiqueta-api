class CreateLineItem < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.string :uuid, null: false
      t.string :order_id, null: false
      t.string :product_type, null: false
      t.string :product_id, null: false
      t.timestamps
    end
  end
end
