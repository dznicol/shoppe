module Shoppe
  class Retailer < Shoppe::ApplicationRecord
    has_and_belongs_to_many :countries, :class_name => 'Shoppe::Country', :join_table => 'shoppe_countries_retailers'
    has_and_belongs_to_many :users, :class_name => 'Shoppe::User', :join_table => 'shoppe_retailers_users'

    has_many :orders, class_name: 'Shoppe::Order', inverse_of: :retailer

    belongs_to :api_user, :class_name => 'Shoppe::User', optional: :true

    # All retailers ordered by their name asending
    scope :ordered, -> { order(name: :asc) }
  end
end
