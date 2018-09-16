module ShipStation
  module V1
    class Base < Grape::API
      mount ShipStation::V1::CustomStore
    end
  end
end
