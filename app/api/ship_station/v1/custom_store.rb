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
          @orders = @retailer.orders.where(created_at: permitted_params[:start_date]..permitted_params[:end_date])
          render rabl: 'shoppe/order/index'
        end

        desc "Retrieve an order"
        params do
          requires :id, type: String, desc: "ID of the order"
        end
        get ":id" do
          @order = @retailer.orders.where(id: permitted_params[:id]).first!
          render rabl: 'shoppe/order/show'
        end
      end
    end
  end
end
