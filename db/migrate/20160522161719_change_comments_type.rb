class ChangeCommentsType < ActiveRecord::Migration
  def up
    execute "ALTER TABLE comments CONVERT  TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin, MODIFY data TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL"
  end

  def down
    #NOOP
  end
end
