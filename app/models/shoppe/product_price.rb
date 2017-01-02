module Shoppe
  class ProductPrice < ActiveRecord::Base

    self.table_name = 'shoppe_product_prices'

    # Validations
    validates :currency, presence: true

    # The associated product
    #
    # @return [Shoppe::Product]
    belongs_to :product, inverse_of: :product_prices, class_name: 'Shoppe::Product'

    # Create/update attributes for a product based on the provided hash of
    # keys & values.
    #
    # @param array [Array]
    def self.update_from_array(array)
      existing_currencies = self.pluck(:currency)
      array.each do |hash|
        next if hash['currency'].blank?
        params = hash.merge({
                                currency: hash['currency'].to_s,
                                price: hash['price']
                            })
        if existing_currency = self.where(currency: hash['currency']).first
          if hash['price'].blank?
            existing_currency.destroy
          else
            existing_currency.update_attributes(params)
          end
        else
          currency = self.create(params)
        end
      end
      self.where(currency: existing_currencies - array.map { |h| h['currency']}).delete_all
      true
    end

  end
end
