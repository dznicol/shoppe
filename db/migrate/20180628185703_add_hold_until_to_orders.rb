class AddHoldUntilToOrders < ActiveRecord::Migration
  def change
    add_column :shoppe_orders, :hold_until, :date
  end
end
