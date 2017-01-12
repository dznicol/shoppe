module Shoppe
  class Retailer < ActiveRecord::Base
    has_and_belongs_to_many :countries, :class_name => 'Shoppe::Country'
    has_and_belongs_to_many :users, :class_name => 'Shoppe::User'

    has_many :orders, class_name: 'Shoppe::Order', inverse_of: :retailer

    # All retailers ordered by their name asending
    scope :ordered, -> { order(name: :asc) }
  end
end
