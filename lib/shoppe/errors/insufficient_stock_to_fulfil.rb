module Shoppe
  module Errors
    class InsufficientStockToFulfil < Shoppe::Error
      
      def order
        @options[:order]
      end
      
      def out_of_stock_items
        @options[:out_of_stock_items]
      end
      
    end
  end
end