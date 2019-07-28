module Shoppe
  class RetailersController < Shoppe::ApplicationController

    before_action { @active_nav = :retailers }
    before_action { params[:id] && @retailer = Shoppe::Retailer.find(params[:id]) }

    def index
      @retailers = Shoppe::Retailer.ordered
    end

    def new
      @retailer = Shoppe::Retailer.new
    end

    def create
      @retailer = Shoppe::Retailer.new(safe_params)
      if @retailer.save
        redirect_to :retailers, :flash => {:notice => t('shoppe.retailers.create_notice')}
      else
        render :action => "new"
      end
    end

    def edit
    end

    def update
      delivery_states = safe_params[:delivery_states]
      if @retailer.update(safe_params.merge({delivery_states: delivery_states.split(/[\s,]+/)}))
        redirect_to [:edit, @retailer], :flash => {:notice => t('shoppe.retailers.update_notice') }
      else
        render :action => "edit"
      end
    end

    def destroy
      @retailer.destroy
      redirect_to :retailers, :flash => {:notice => t('shoppe.retailers.destroy_notice')}
    end

    private

    def safe_params
      params[:retailer].permit(:name, :region, :api_key, :api_user_id, :delivery_states, country_ids: [], user_ids: [])
    end

  end
end
