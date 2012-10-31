class AddDetailsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :customer_id, :integer

    add_column :orders, :tax_line, :float

    add_column :orders, :shopifystores_id, :integer

    add_column :orders, :product_id, :integer

  end
end
