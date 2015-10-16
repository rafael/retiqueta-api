class AddAttachmentPicToProfiles < ActiveRecord::Migration
  def self.up
    change_table :profiles do |t|
      t.attachment :pic
    end
  end

  def self.down
    remove_attachment :profiles, :pic
  end
end
