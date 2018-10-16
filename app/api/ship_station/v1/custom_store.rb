module ShipStation
  module V1
    class CustomStore < Grape::API

      include Defaults

      resource :orders do
        desc "Retrieve all orders for logged in retailer"
        params do
          requires :action, type: String, values: ['export'], desc: "Must be 'export'"
          requires :start_date, type: DateTime, coerce_with: ->(d) { DateTime.strptime(d, '%m/%d/%Y %H:%M') }, desc: "Earliest order date"
          requires :end_date, type: DateTime, coerce_with: ->(d) { DateTime.strptime(d, '%m/%d/%Y %H:%M') }, desc: "Latest order date"
        end
        get "" do
          @orders = Shoppe::Order.for_retailer(@retailer)
                        .where(updated_at: permitted_params[:start_date]..permitted_params[:end_date])
                        .where.not(status: [:building, :confirming])
          render rabl: 'shoppe/order/index'
        end

        desc "Retrieve an order"
        params do
          requires :id, type: Integer, desc: "ID of the order"
        end
        get ":id" do
          @order = @retailer.orders.where(id: permitted_params[:id]).first!
          render rabl: 'shoppe/order/show'
        end

        desc "Update an order"
        params do
          requires :action, type: String, values: ['shipnotify'], desc: "Must be 'shipnotify'"
          requires :order_number, type: Integer, desc: "ID of the order"
          requires :carrier, type: String, desc: "Carrier for the order"
          optional :service, type: String, desc: "Carrier service for the order"
          requires :tracking_number, type: String, desc: "Tracking number for the order"
        end
        post "" do
          @order = Shoppe::Order.for_retailer(@retailer)
                       .where(id: permitted_params[:order_number]).first!
          @order.accept!(@retailer.api_user) unless @order.accepted?
          @order.ship!(permitted_params[:tracking_number], @retailer.api_user)
          render rabl: 'shoppe/order/update'
        end
      end
    end
  end
end
