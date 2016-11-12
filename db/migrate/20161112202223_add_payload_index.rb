class AddPayloadIndex < ActiveRecord::Migration
   def up
     execute <<-SQL
       CREATE INDEX timeline_cards_payload_idx ON timeline_cards ((payload->'product_ids'))
     SQL
   end

   def down
     execute <<-SQL
       DROP INDEX timeline_cards_payload_idx
     SQL
   end
end
