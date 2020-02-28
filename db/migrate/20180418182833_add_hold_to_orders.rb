class AddHoldToOrders < ActiveRecord::Migration[4.2]
  def change
    add_column :shoppe_orders, :held_at, :string
    add_column :shoppe_orders, :held_by, :integer
    add_column :shoppe_orders, :unheld_by, :integer
  end
end
