class CreatePaymentAuditTrail < ActiveRecord::Migration
  def change
    create_table :payment_audit_trails do |t|
      t.string :uuid, null: false
      t.string :user_id, null: false
      t.string :action, null: false
      t.text :metadata
      t.timestamps null: false
    end

    add_index :payment_audit_trails, :user_id
  end
end
