class AddReturnedAtToOrder < ActiveRecord::Migration[4.2]
  def change
    add_column :shoppe_orders, :returned_at, :datetime
    add_column :shoppe_orders, :returned_by, :integer
  end
end
