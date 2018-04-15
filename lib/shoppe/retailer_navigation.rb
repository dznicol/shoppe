require 'shoppe/navigation_manager'

# This file defines all the retailer navigation managers used in Multi-Currency Shoppe.
# This file is loaded on application initialization so if you make changes, you'll need
# to restart the webserver.

#
# This is the default navigation manager for the admin interface.
#
Shoppe::NavigationManager.build(:retailer) do
  add_item :orders
  add_item :customers
  add_item :delivery_services
end
