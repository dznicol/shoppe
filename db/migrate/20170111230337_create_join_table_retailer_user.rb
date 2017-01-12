class CreateJoinTableRetailerUser < ActiveRecord::Migration
  def change
    create_join_table(:retailers, :users, table_name: :shoppe_retailers_users) do |t|
      # t.index [:retailer_id, :user_id]
      t.index [:user_id, :retailer_id]
    end
  end
end
