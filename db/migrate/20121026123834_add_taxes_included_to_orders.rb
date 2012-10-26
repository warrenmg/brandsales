class AddTaxesIncludedToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :taxes_included, :boolean

  end
end
