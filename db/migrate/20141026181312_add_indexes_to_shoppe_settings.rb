class AddIndexesToShoppeSettings < ActiveRecord::Migration[4.2]
  def change
    add_index :shoppe_settings, :key
  end
end
