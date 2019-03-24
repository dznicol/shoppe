class AddDeliveryStatesToRetailers < ActiveRecord::Migration[5.0]
  def change
    add_column :shoppe_retailers, :delivery_states, :string, array: true, default: []
  end
end
