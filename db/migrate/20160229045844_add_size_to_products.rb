class AddSizeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :size, :string, length: 20
  end
end
