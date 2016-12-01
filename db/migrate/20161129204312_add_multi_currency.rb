class AddMultiCurrency < ActiveRecord::Migration
  def change

    # Match on currency as well as weight when searching for delivery services
    add_column :shoppe_delivery_service_prices, :currency, :string
    add_index :shoppe_delivery_service_prices, [:currency], name: :index_shoppe_delivery_service_prices_on_currency

    add_column :shoppe_orders, :currency, :string

    create_table :shoppe_product_prices do |t|
      t.integer  :product_id
      t.string   :currency
      t.decimal  :price,              precision: 8, scale: 2, default: 0.0
      t.decimal  :cost_price,         precision: 8, scale: 2, default: 0.0
    end

    add_index :shoppe_product_prices, [:product_id], name: :index_shoppe_product_prices_on_product_id, using: :btree
  end
end
