class AddAddressTypeToShoppeTaxRates < ActiveRecord::Migration[4.2]
  def change
    add_column :shoppe_tax_rates, :address_type, :string
  end
end
