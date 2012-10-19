class AddPaidStatusToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :paid_status, :string

    add_column :orders, :shipped_status, :string

  end
end
