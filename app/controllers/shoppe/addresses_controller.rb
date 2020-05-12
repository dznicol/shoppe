module Shoppe
  class AddressesController < Shoppe::ApplicationController

    before_action { @active_nav = :customers }
    before_action { params[:customer_id] && @customer = Shoppe::Customer.find(params[:customer_id])}
    before_action { params[:id] && @address = @customer.addresses.find(params[:id])}

    def new
      @address = Shoppe::Address.new
    end

    def edit
    end

    def create
      @address = @customer.addresses.build(safe_params)
      if @customer.addresses.count == 0
        @address.default = true
      end
      if @customer.save
        redirect_to @customer, :flash => {:notice => "Address has been created, please update any existing reference to old addresses!"}
      else
        render action: "new"
      end
    end

    def update
      if @address.update(safe_params)
        redirect_to @customer, :flash => {:notice => "Address has been updated successfully"}
      else
        render action: "edit"
      end
    end

    def destroy
      begin
        @address.destroy
        redirect_to @customer, :flash => {:notice => "Address has been deleted successfully"}
      rescue => e
        redirect_to @customer, :flash => {:alert => "Address cannot be deleted. #{e.message}"}
      end
    end

    private
  
    def safe_params
      params[:address].permit(:address_type, :address1, :address2, :address3, :address4, :postcode, :country_id)
    end

  end
end