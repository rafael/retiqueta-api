class ChangeFeaturedTypeInProducts < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE products DROP COLUMN featured'
    execute 'ALTER TABLE products ADD COLUMN featured boolean'
  end

  def down
    # NOOP
  end
end
