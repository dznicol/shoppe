class AddRetailerToOrder < ActiveRecord::Migration[4.2]
  def change
    add_reference :shoppe_orders, :retailer, index: true
    add_foreign_key :shoppe_orders, :shoppe_retailers, column: :retailer_id
  end
end
