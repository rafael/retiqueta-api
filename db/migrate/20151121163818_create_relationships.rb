class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.string :follower_id, null: false
      t.string :followed_id, null: false

      t.timestamps null: false
    end
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
