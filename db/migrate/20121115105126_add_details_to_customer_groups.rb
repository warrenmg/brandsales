class AddDetailsToCustomerGroups < ActiveRecord::Migration
  def change
    add_column :customergroups, :shopifystores_id, :integer

  end
end
