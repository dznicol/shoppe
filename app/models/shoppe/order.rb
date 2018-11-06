require 'csv'

module Shoppe
  class Order < Shoppe::ApplicationRecord

    EMAIL_REGEX = /\A\b[A-Z0-9\.\_\%\-\+]+@(?:[A-Z0-9\-]+\.)+[A-Z]{2,6}\b\z/i
    PHONE_REGEX = /\A[+?\d\ \-x\(\)]{7,}\z/

    DEFAULT_CSV_FORMAT = [
        { title: 'Number', attribute: 'number', },
        { title: 'Status', attribute: 'status', },
        { title: 'Total Items', attribute: 'total_items', },
        { title: 'Delivery Name', attribute: 'delivery_name', },
        { title: 'Email Address', attribute: 'email_address', },
        { title: 'Delivery Address 1', attribute: 'delivery_address1', },
        { title: 'Deliver Address 2', attribute: 'delivery_address2', },
        { title: 'Delivery Address 3', attribute: 'delivery_address3', },
        { title: 'Delivery Address 4', attribute: 'delivery_address4', },
        { title: 'Delivery Postcode', attribute: 'delivery_postcode', },
        { title: 'Phone Number', attribute: 'phone_number', },
    ]

    DEFAULT_SHIP_NOTIFY_MAPPING = {
        order_number: 'Order',
        tracking_number: 'Tracking Number'
    }

    cattr_accessor :csv_format
    @@csv_format = DEFAULT_CSV_FORMAT

    cattr_accessor :ship_notify_mapping
    @@ship_notify_mapping = DEFAULT_SHIP_NOTIFY_MAPPING

    self.table_name = 'shoppe_orders'

    # Orders can have properties
    key_value_store :properties

    # Require dependencies
    require_dependency 'shoppe/order/states'
    require_dependency 'shoppe/order/actions'
    require_dependency 'shoppe/order/billing'
    require_dependency 'shoppe/order/delivery'

    # All items which make up this order
    has_many :order_items, dependent: :destroy, class_name: 'Shoppe::OrderItem', inverse_of: :order
    accepts_nested_attributes_for :order_items, allow_destroy: true, reject_if: Proc.new { |a| a['ordered_item_id'].blank? }

    # All products which are part of this order (accessed through the items)
    has_many :products, through: :order_items, class_name: 'Shoppe::Product', source: :ordered_item, source_type: 'Shoppe::Product'

    # The order can belong to a customer
    belongs_to :customer, class_name: 'Shoppe::Customer'
    has_many :addresses, through: :customers, class_name: 'Shoppe::Address'

    belongs_to :retailer, class_name: 'Shoppe::Retailer'

    # Validations
    validates :token, presence: true
    with_options if: Proc.new { |o| !o.building? } do |order|
      order.validates :email_address, format: { with: EMAIL_REGEX }
      order.validates :phone_number, format: { with: PHONE_REGEX }
    end

    # Set some defaults
    before_validation { self.token = SecureRandom.uuid  if self.token.blank? }

    # Some methods for setting the billing & delivery addresses
    attr_accessor :save_addresses, :billing_address_id, :delivery_address_id

    # The order number
    #
    # @return [String] - the order number padded with at least 5 zeros
    def number
      id ? id.to_s.rjust(6, '0') : nil
    end

    # The length of time the customer spent building the order before submitting it to us.
    # The time from first item in basket to received.
    #
    # @return [Float] - the length of time
    def build_time
      return nil if self.received_at.blank?
      self.created_at - self.received_at
    end

    # The name of the customer in the format of "Company (First Last)" or if they don't have
    # company specified, just "First Last".
    #
    # @return [String]
    def customer_name
      company.blank? ? full_name : "#{company} (#{full_name})"
    end

    # The full name of the customer created by concatinting the first & last name
    #
    # @return [String]
    def full_name
      "#{first_name} #{last_name}"
    end

    # Is this order empty? (i.e. doesn't have any items associated with it)
    #
    # @return [Boolean]
    def empty?
      order_items.empty?
    end

    # Does this order have items?
    #
    # @return [Boolean]
    def has_items?
      total_items > 0
    end

    # Return the number of items in the order?
    #
    # @return [Integer]
    def total_items
      order_items.inject(0) { |t,i| t + i.quantity }
    end

    # SKU summary
    #
    # @return [String]
    def sku_summary
      order_items.map { |item| item.ordered_item.sku }.to_sentence(two_words_connector: ' & ', last_word_connector: ' & ')
    end

    # SKU summary
    #
    # @return [String]
    def summary
      order_items.map { |item| item.ordered_item.name }.to_sentence(two_words_connector: ' & ', last_word_connector: ' & ')
    end

    def self.add_csv_headers(csv)
      csv << csv_format.map do |col|
        col[:title]
      end
    end

    def self.add_csv_row(csv, order)
      csv << Shoppe::Order.csv_format.map do |col|
        attribute = col[:attribute]

        if attribute.present? and order.respond_to?(attribute)
          value = order.send(attribute)
        else
          value = attribute.presence || ''
        end

        if col[:use_if_empty].present? and [nil, '', '-'].include?(value)
          value = order.send(col[:use_if_empty]) if order.respond_to?(col[:use_if_empty])
        end

        if col[:drop_if_empty].present? and order.respond_to?(col[:drop_if_empty])
          value = '' if [nil, '', '-'].include?(order.send(col[:drop_if_empty]))
        end

        value
      end
    end

    def self.ransackable_attributes(auth_object = nil)
      ["id", "billing_postcode", "billing_address1", "billing_address2", "billing_address3", "billing_address4",
       "first_name", "last_name", "company", "email_address", "phone_number", "consignment_number", "status",
       "received_at", "currency"] + _ransackers.keys
    end

    def self.ransackable_associations(auth_object = nil)
      []
    end

    def to_csv
      CSV.generate(headers: true) do |csv|
        Shoppe::Order.add_csv_headers(csv)
        Shoppe::Order.add_csv_row(csv, self)
      end
    end

    def self.to_csv
      CSV.generate(headers: true) do |csv|
        Shoppe::Order.add_csv_headers(csv)
        all.each do |order|
          Shoppe::Order.add_csv_row(csv, order)
        end
      end
    end

    def self.bulk_ship_notify(file, user = nil)
      spreadsheet = Roo::Spreadsheet.open(file.path)
      header = spreadsheet.row(1)
      not_found = []
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]

        if @@ship_notify_mapping[:order_number].is_a?(Integer)
          order_number = spreadsheet.row(i)[@@ship_notify_mapping[:order_number]]
        else
          order_number = row[@@ship_notify_mapping[:order_number]]
        end

        if @@ship_notify_mapping[:tracking_number].is_a?(Integer)
          tracking_number = spreadsheet.row(i)[@@ship_notify_mapping[:tracking_number]]
        else
          tracking_number = row[@@ship_notify_mapping[:tracking_number]]
        end

        order = find_by(id: order_number)
        if order.present?
          order.accept!(user) unless order.accepted?
          order.ship!(tracking_number, user)
        else
          not_found << order_number
        end
      end
      not_found
    end

  end
end
