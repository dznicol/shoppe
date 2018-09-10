module Shoppe
  module Errors
    class NotEnoughStock < Shoppe::Error
      
      def available_stock
        @options[:ordered_item].stock
      end
      
      def requested_stock
        @options[:requested_stock]
      end
      
    end
  end
end