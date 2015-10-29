class CreateProductPictures < ActiveRecord::Migration
  def change
    create_table :product_pictures do |t|
      t.string :user_id, index: true
      t.string :product_id, index: true
      t.integer :position
      t.timestamps null: false
    end
  end
end
