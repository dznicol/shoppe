class AddApiKeyToRetailer < ActiveRecord::Migration[5.0]
  def change
    add_column :shoppe_retailers, :api_key, :string
  end
end
