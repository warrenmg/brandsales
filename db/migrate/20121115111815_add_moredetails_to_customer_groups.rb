class AddMoredetailsToCustomerGroups < ActiveRecord::Migration
  def change
    add_column :customergroups, :customergroup_id, :integer
    add_index :customergroups, :customergroup_id

  end
end
