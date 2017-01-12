module Shoppe
  class Retailer < ActiveRecord::Base
    has_and_belongs_to_many :countries, :class_name => 'Shoppe::Country'
    has_and_belongs_to_many :users, :class_name => 'Shoppe::User'

    # All retailers ordered by their name asending
    scope :ordered, -> { order(name: :asc) }
  end
end
