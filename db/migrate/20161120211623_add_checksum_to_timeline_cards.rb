class AddChecksumToTimelineCards < ActiveRecord::Migration
  def change
    add_column :timeline_cards, :checksum, :string
    add_index :timeline_cards, :checksum, unique: true
  end
end
