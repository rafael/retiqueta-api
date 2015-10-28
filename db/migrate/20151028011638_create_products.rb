class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :title
      t.text :description
      t.string :category
      t.float :price
      t.float :original_price
      t.float :featured
      t.string :currency
      t.string :status
      t.string :location
      t.string :lat_lon

      t.timestamps null: false
    end
  end
end
