class RemoveShippingAddressFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :shipping_address, :string
  end
end
