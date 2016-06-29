class AddStoreFeeToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :store_fee, :float, default: 0.0
  end
end
