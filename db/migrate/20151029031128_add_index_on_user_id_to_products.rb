class AddIndexOnUserIdToProducts < ActiveRecord::Migration
  def change
    add_index :products, :user_id
  end
end
