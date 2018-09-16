require 'grape'

module ShipStation
  class Base < Grape::API
    mount ShipStation::V1::Base
  end
end
