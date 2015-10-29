class ChangeFeaturedTypeInProducts < ActiveRecord::Migration
  def change
    change_column :products, :featured, :boolean
  end
end
