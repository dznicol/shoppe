class CreateShoppeRetailers < ActiveRecord::Migration[4.2]
  def change
    create_table :shoppe_retailers do |t|
      t.string :name
      t.string :region

      t.timestamps
    end
  end
end
