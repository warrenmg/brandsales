class RemoveDetailsFromCustomerGroups < ActiveRecord::Migration
  def up
    remove_column :customergroups, :customergroup_id
        remove_column :customergroups, :integer
      end

  def down
    add_column :customergroups, :integer, :string
    add_column :customergroups, :customergroup_id, :string
  end
end
