class AddShopifyOwnerToOrders < ActiveRecord::Migration
  def self.up
  add_column :orders, :shopify_owner,:string
  end
  
  def self.down
  remove_column :orders,:shopify_owner
  end
end
