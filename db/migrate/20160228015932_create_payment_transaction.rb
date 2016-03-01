class CreatePaymentTransaction < ActiveRecord::Migration
  def change
    create_table :payment_transactions do |t|
      t.string :uuid, null: false
      t.string :user_id, null: false
      t.string :status
      t.text :metadata
      t.timestamps
    end
  end
end
