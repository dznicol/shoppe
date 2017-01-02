module Shoppe
  class Product < ActiveRecord::Base

    # Currencies we support for this product beyond native currency
    has_many :product_prices, inverse_of: :product, dependent: :destroy, class_name: 'Shoppe::ProductPrice'

    # Used for setting an array of product prices which will be updated. Usually
    # received from a web browser.
    attr_accessor :product_prices_array

    # After saving automatically try to update the product prices based on the
    # the contents of the product_prices_array array.
    after_save do
      if product_prices_array.is_a?(Array)
        self.product_prices.update_from_array(product_prices_array)
      end
    end

  end
end
