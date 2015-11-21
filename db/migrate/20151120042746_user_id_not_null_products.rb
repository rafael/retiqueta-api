class UserIdNotNullProducts < ActiveRecord::Migration
  def change
    change_column :products, :user_id, :string, null: false
  end
end
