class BackfillProductConversation < ActiveRecord::Migration
  def self.up
    Product.find_each do |product|
      product.create_conversation!
    end
  end

  def self.down
    #NOOP
  end
end
