class AddUserIdToTimelineCards < ActiveRecord::Migration
  def change
    add_column :timeline_cards, :user_id, :string
    add_index :timeline_cards, :user_id
  end
end
