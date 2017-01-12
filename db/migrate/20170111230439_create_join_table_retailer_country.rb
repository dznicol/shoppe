class CreateJoinTableRetailerCountry < ActiveRecord::Migration
  def change
    create_join_table(:retailers, :countries, table_name: :shoppe_countries_retailers) do |t|
      t.index [:retailer_id, :country_id]
      # t.index [:country_id, :retailer_id]
    end
  end
end
