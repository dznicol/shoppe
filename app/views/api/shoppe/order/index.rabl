collection @orders, root: :Orders, object_root: false
attributes id: :OrderID,
           number: :OrderNumber,
           created_at: :OrderDate,
           status: :OrderStatus,
           updated_at: :LastModified,
           total: :OrderTotal,
           notes: :InternalNotes
node :Customer do |order|
  {
      CustomerCode: order.email_address,
      BillTo: {
          Name: order.full_name,
          Address1: order.billing_address1,
          Address2: order.billing_address2,
          City: order.billing_address3,
          State: order.billing_address4,
          PostalCode: order.billing_postcode,
          Country: order.billing_country.code2,
          Phone: order.phone_number
      },
      ShipTo: {
          Name: order.delivery_name,
          Address1: order.delivery_address1,
          Address2: order.delivery_address2,
          City: order.delivery_address3,
          State: order.delivery_address4,
          PostalCode: order.delivery_postcode,
          Country: order.delivery_country.code2,
          Phone: order.phone_number
      }
  }
end
child :order_items => :Items do
  node(:SKU) { |order_item| order_item.ordered_item.sku }
  node(:Name) { |order_item| order_item.ordered_item.name }
  node(:ImageUrl) { |order_item| order_item.ordered_item.default_image }
  node(:Weight) { |order_item| order_item.ordered_item.weight }
  node(:WeightUnits) { 'kg' }
  node(:Quantity) { |order_item| order_item.quantity }
  node(:Price) { |order_item| order_item.ordered_item.price(order_item.order.currency) }
end
