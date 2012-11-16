class CreateCustomergroupsCustomers < ActiveRecord::Migration
  def change
    create_table :customergroups_customers do |t|
      t.integer :customergroup_id
      t.integer :customer_id

      t.timestamps
    end
  end
end
