class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.integer :shopifystores_id
      t.integer :shopify_customer_id
      t.string :first_name
      t.string :last_name
      t.string :country
      t.string :tags
      t.string :state

      t.timestamps
    end
  end
end
