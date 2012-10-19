class CreateShopifystores < ActiveRecord::Migration
  def change
    create_table :shopifystores do |t|
      t.string :name
      t.string :status
      t.datetime :lastorderupdate
      t.string :currency
      t.string :taxesincluded
      t.string :shopifyplan
      t.string :shopify_owner
      t.string :email


      t.timestamps
    end

  end
end
