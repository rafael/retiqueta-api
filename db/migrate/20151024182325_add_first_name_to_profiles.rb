class AddFirstNameToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :first_name, :string
  end
end
