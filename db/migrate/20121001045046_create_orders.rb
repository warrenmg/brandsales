class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :shopify_order_id
      t.string :shopify_name
      t.datetime :order_date
      t.integer :no_of_items
      t.float :price
      t.string :vendor_name

      t.timestamps
    end
  end
end
