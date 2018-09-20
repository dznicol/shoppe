class AddApiUserToRetailer < ActiveRecord::Migration[5.0]
  def change
    add_reference :shoppe_retailers, :api_user
    add_foreign_key :shoppe_retailers, :shoppe_users, column: :api_user_id
  end
end
