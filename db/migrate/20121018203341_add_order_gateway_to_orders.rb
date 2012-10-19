class AddOrderGatewayToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :subtotal_price, :float

    add_column :orders, :total_tax, :float

    add_column :orders, :cancelled_at, :datetime

    add_column :orders, :gateway, :string

    add_column :orders, :processing_method, :string

  end
end
