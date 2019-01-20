class AddNameToDeliveryServicePrice < ActiveRecord::Migration[5.0]
  def change
    add_column :shoppe_delivery_service_prices, :name, :string
  end
end
