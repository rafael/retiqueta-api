class CreateMpCustomers < ActiveRecord::Migration
  def change
    create_table :mp_customers, id: :uuid do |t|
      t.string :user_id, null: false
      t.jsonb :payload, null: false
      t.timestamps null: false
    end

    add_index :mp_customers, :user_id, unique: true
  end
end
