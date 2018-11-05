module Shoppe
  class OrdersController < Shoppe::ApplicationController

    before_action { @active_nav = :orders }
    before_action { params[:id] && params[:id].to_i.to_s == params[:id] && @order = Shoppe::Order.find(params[:id])}

    def index
      @all_statuses = Shoppe::Order::STATUSES
      if session['order_status_filter'].present?
        @selected_statuses = session['order_status_filter']
      else
        @selected_statuses = Shoppe::Order::STATUSES.select { |el| %w(received accepted).include?(el) }
      end

      if request.format.html?
        @query = Shoppe::Order.for_user(current_user).ordered.received
                     .includes(order_items: :ordered_item)
                     .includes(:retailer)
                     .where(status: @selected_statuses)
                     .page(params[:page]).search(params[:q])
      else
        @query = Shoppe::Order.for_user(current_user).ordered.received
                     .includes(order_items: :ordered_item)
                     .includes(:retailer)
                     .where(status: @selected_statuses)
                     .search(params[:q])
      end

      @orders = @query.result
      @retailers = Shoppe::Retailer.all

      respond_to do |format|
        format.html { render :index }
        format.csv { send_data @orders.to_csv, filename: "orders-#{Date.today}.csv" }
      end
    end

    def retailer
      @retailer = params[:retailer]
    end

    def status
      session['order_status_filter'] = params[:statuses]
      redirect_to orders_path
    end

    def new
      @order = Shoppe::Order.new
      @order.order_items.build(:ordered_item_type => 'Shoppe::Product')
    end

    def create
      Shoppe::Order.transaction do
        @order = Shoppe::Order.new(safe_params)
        @order.status = 'confirming'

        if safe_params[:customer_id]
          @customer = Shoppe::Customer.find safe_params[:customer_id]
          @order.first_name = @customer.first_name
          @order.last_name = @customer.last_name
          @order.company = @customer.company
          @order.email_address = @customer.email
          @order.phone_number = @customer.phone
          if @customer.addresses.billing.present?
            billing = @customer.addresses.billing.first
            @order.billing_address1 = billing.address1
            @order.billing_address2 = billing.address2
            @order.billing_address3 = billing.address3
            @order.billing_address4 = billing.address4
            @order.billing_postcode = billing.postcode
            @order.billing_country_id = billing.country_id
          end
          if @customer.addresses.delivery.present?
            delivery = @customer.addresses.delivery.first
            @order.delivery_address1 = delivery.address1
            @order.delivery_address2 = delivery.address2
            @order.delivery_address3 = delivery.address3
            @order.delivery_address4 = delivery.address4
            @order.delivery_postcode = delivery.postcode
            @order.delivery_country_id = delivery.country_id
          end
        end

        if !request.xhr? && @order.save
          @order.confirm!
          redirect_to @order, :notice => t('shoppe.orders.create_notice')
        else
          @order.order_items.build(:ordered_item_type => 'Shoppe::Product')
          render :action => "new"
        end
      end
    rescue Shoppe::Errors::InsufficientStockToFulfil => e
      flash.now[:alert] = t('shoppe.orders.insufficient_stock_order', out_of_stock_items: e.out_of_stock_items.map { |t| t.ordered_item.full_name }.to_sentence)
      render :action => 'new'
    end

    def show
      @payments = @order.payments.to_a

      respond_to do |format|
        format.html
        format.csv { send_data @order.to_csv, filename: "order-#{@order.number}-#{@order.status}.csv" }
      end
    end

    def update
      @order.attributes = safe_params

      if @order.hold_until.blank? and params[:hold_until].present? and params[:hold_until] > Date.today
        @order.hold!(current_user, params[:hold_until])
      elsif params[:hold_until].present? and params[:hold_until] > Date.today
        @order.hold_until = nil
      end

      if !request.xhr? && @order.update_attributes(safe_params)
        redirect_to @order, :notice => t('shoppe.orders.update_notice')
      else
        render :action => "edit"
      end
    end

    def search
      index
    end

    def accept
      @order.accept!(current_user)
      redirect_to @order, :notice => t('shoppe.orders.accept_notice')
    rescue Shoppe::Errors::PaymentDeclined => e
      redirect_to @order, :alert => e.message
    end

    def reject
      @order.reject!(current_user)
      redirect_to @order, :notice => t('shoppe.orders.reject_notice')
    rescue Shoppe::Errors::PaymentDeclined => e
      redirect_to @order, :alert => e.message
    end

    def ship
      @order.update(delivery_service: @order.available_delivery_services.select { |s| s.id == params[:delivery_service].to_i}.first)

      @order.ship!(params[:consignment_number], current_user)
      redirect_to @order, :notice => t('shoppe.orders.ship_notice')
    end

    def return
      @order.return!(current_user)
      redirect_to @order, :notice => t('shoppe.orders.return_notice')
    end

    def hold
      @order.hold!(current_user)
      redirect_to @order, :notice => t('shoppe.orders.hold_notice')
    end

    def unhold
      @order.unhold!(current_user)
      redirect_to @order, :notice => t('shoppe.orders.unhold_notice')
    end

    def despatch_note
      render :layout => 'shoppe/printable'
    end

    def ship_notify
      if params[:ship_notify].nil?
        redirect_to orders_path, :flash => {:alert => I18n.t('shoppe.imports.errors.no_file')}
      else
        not_found = Order.bulk_ship_notify(params[:ship_notify][:file])
        if not_found.present?
          redirect_to orders_path, :notice => t('shoppe.orders.failed_to_ship_notify', :order_nums => not_found.join(','))
        else
          redirect_to orders_path, :flash => {:alert => t('shoppe.orders.ship_notice')}
        end
      end
    end

    private

    def safe_params
      params[:order].permit(
        :customer_id,
        :first_name, :last_name, :company,
        :billing_address1, :billing_address2, :billing_address3, :billing_address4, :billing_postcode, :billing_country_id,
        :separate_delivery_address,
        :delivery_name, :delivery_address1, :delivery_address2, :delivery_address3, :delivery_address4, :delivery_postcode, :delivery_country_id,
        :delivery_price, :delivery_service_id, :delivery_tax_amount,
        :email_address, :phone_number,
        :notes, :retailer_id, :currency, :hold_until,
        :order_items_attributes => [:ordered_item_id, :ordered_item_type, :quantity, :unit_price, :tax_amount, :id, :weight]
      )
    end
  end
end
