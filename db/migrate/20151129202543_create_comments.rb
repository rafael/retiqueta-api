class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :conversation_id
      t.string :uuid, null: false
      t.string :user_id, null: false
      t.text :data, null: false
      t.string :user_pic

      t.timestamps null: false
    end

    add_index :comments, :conversation_id
  end
end
