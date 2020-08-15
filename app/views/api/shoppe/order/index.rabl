collection @orders, root: :Orders, object_root: false
attributes id: :OrderID,
           number: :OrderNumber,
           cstatus: :OrderStatus,
           total: :OrderTotal,
           notes: :InternalNotes
node :OrderDate do |order|
  # 12/8/2011 21:56 PM
  order.created_at.strftime('%-m/%d/%Y %H:%M %p')
end
node :LastModified do |order|
  # 12/8/2011 21:56 PM
  order.updated_at.strftime('%-m/%d/%Y %H:%M %p')
end
node :Customer do |order|
  {
      CustomerCode: (order.customer_id.present? ? "CUST#{order.customer_id}" : order.email_address),
      BillTo: {
          Name: order.full_name,
          Address1: ([nil, '', '-'].include?(order.billing_address1) ? order.billing_address2 : order.billing_address1),
          Address2: ([nil, '', '-'].include?(order.billing_address1) ?  '' : order.billing_address2),
          City: order.billing_address3,
          State: order.billing_address4,
          PostalCode: order.billing_postcode,
          Country: order.billing_country.code2,
          Phone: order.phone_number,
          Email: order.email_address
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
  node(:Weight) { |order_item| order_item.ordered_item.weight * 1000 }
  node(:WeightUnits) { 'Grams' }
  node(:Quantity) { |order_item| order_item.quantity }
  node(:UnitPrice) { |order_item| order_item.ordered_item.price(order_item.order.currency) }
end
