class Product < ActiveRecord::Base
  belongs_to :user, primary_key: :uuid
  has_many :product_pictures
end
