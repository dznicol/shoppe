class AddIndexesToShoppeUsers < ActiveRecord::Migration[4.2]
  def change
    add_index :shoppe_users, :email_address
  end
end
