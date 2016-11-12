class CreateTimelineCards < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :timeline_cards, id: :uuid do |t|
      t.string :title, null: false
      t.string :card_type, null: false
      t.jsonb :payload, null: false
      t.timestamps null: false
    end
    add_index :timeline_cards, :card_type
  end
end
