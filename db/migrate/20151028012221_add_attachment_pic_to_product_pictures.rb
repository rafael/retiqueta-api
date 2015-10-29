class AddAttachmentPicToProductPictures < ActiveRecord::Migration
  def self.up
    change_table :product_pictures do |t|
      t.attachment :pic
    end
  end

  def self.down
    remove_attachment :product_pictures, :pic
  end
end
