class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :conversation_id
      t.string :uuid
      t.string :user_id
      t.string :string
      t.text :data
      t.string :user_picture

      t.timestamps null: false
    end

    add_index :comments, :conversation_id
  end
end
