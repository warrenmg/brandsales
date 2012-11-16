class CreateCustomergroups < ActiveRecord::Migration
  def change
    create_table :customergroups do |t|
      t.string :name
      t.string :customergroup_id
      t.string :integer

      t.timestamps
    end
  end
end
