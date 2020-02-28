class AddCustomerToShoppeOrders < ActiveRecord::Migration[4.2]
  def change
    add_column :shoppe_orders, :customer_id, :integer
  end
end
