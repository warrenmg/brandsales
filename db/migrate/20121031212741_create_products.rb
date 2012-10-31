class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :shopifystores_id
      t.string :title
      t.integer :shopify_product_id
      t.string :tags
      t.string :product_type
      t.float :price
      t.string :sku
      t.integer :inventory_qty

      t.timestamps
    end
  end
end
