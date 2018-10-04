# require 'grape-active_model_serializers'
require 'grape-rabl'
require 'grape_logging'

module ShipStation
  module V1
    module Defaults
      extend ActiveSupport::Concern

      included do
        prefix "api/ship_station"
        version "v1", using: :path
        format :xml
        formatter :xml, Grape::Formatter::Rabl
        # content_type :xml, 'application/xml' # Default accepts XML, JSON, BINARY, and TXT
        default_format :xml

        use GrapeLogging::Middleware::RequestLogger, { logger: logger, log_level: 'debug' }

        # use ShipStation::DebugMiddleware, { logger: logger }

        helpers do
          def permitted_params
            @permitted_params ||= declared(params, include_missing: false)
          end

          def logger
            Rails.logger
          end
        end

        http_basic do |retailer_name, api_key|
          retailer = Shoppe::Retailer.find_by name: retailer_name
          @retailer = retailer.present? && retailer.api_key == api_key ? retailer : nil
          @retailer.present?
        end

        rescue_from :all do |e|
          logger.error(e)
          if e.respond_to?(:status)
            error!(e.to_json, e.status, e.headers, e.backtrace)
          else
            error! "Internal Server Error"
          end
        end
        # rescue_from ActiveRecord::RecordNotFound do |e|
        #   logger.error(e)
        #   error_response(message: e.message, status: 404)
        # end
        #
        # rescue_from ActiveRecord::RecordInvalid do |e|
        #   logger.error(e)
        #   error_response(message: e.message, status: 422)
        # end
      end
    end
  end
end
