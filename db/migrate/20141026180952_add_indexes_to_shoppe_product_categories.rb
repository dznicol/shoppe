class AddIndexesToShoppeProductCategories < ActiveRecord::Migration[4.2]
  def change
    add_index :shoppe_product_categories, :permalink
  end
end
