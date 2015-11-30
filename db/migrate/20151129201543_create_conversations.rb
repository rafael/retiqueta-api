class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.integer :commentable_id
      t.string :commentable_type

      t.timestamps null: false
    end

    add_index :conversations, [:commentable_id, :commentable_type], unique: true
  end
end
