class AddDetailsToCustomerGroupsCustomers < ActiveRecord::Migration
  def change
    add_column :customergroups_customers, :shopifystores_id, :integer

  end
end
