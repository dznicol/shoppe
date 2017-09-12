class AddUsStatesToTaxRates < ActiveRecord::Migration
  def change
    add_column :shoppe_tax_rates, :state_codes, :text
    add_column :shoppe_delivery_service_prices, :state_codes, :text
  end
end
