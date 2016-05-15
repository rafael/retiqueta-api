class CreatePayouts < ActiveRecord::Migration
  def change
    create_table :payouts do |t|
      t.string :user_id, index: true
      t.string :uuid
      t.float :amount, null: false
      t.string :status, null: false, limit: 40
      t.timestamps null: false
    end
  end
end
