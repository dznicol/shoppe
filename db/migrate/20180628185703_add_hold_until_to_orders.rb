class AddHoldUntilToOrders < ActiveRecord::Migration[4.2]
  def change
    add_column :shoppe_orders, :hold_until, :date
  end
end
