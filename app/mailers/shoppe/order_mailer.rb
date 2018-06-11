module Shoppe
  class OrderMailer < ActionMailer::Base
  
    def received(order)
      @order = order
      mail :from => Shoppe.settings.outbound_email_address, :to => order.email_address, :subject => I18n.t('shoppe.order_mailer.received.subject', :default => "Order Confirmation")
    end
  
    def accepted(order)
      @order = order
      mail :from => Shoppe.settings.outbound_email_address, :to => order.email_address, :subject => I18n.t('shoppe.order_mailer.accepted.subject', :default => "Order Accepted")
    end
  
    def rejected(order)
      @order = order
      mail :from => Shoppe.settings.outbound_email_address, :to => order.email_address, :subject => I18n.t('shoppe.order_mailer.rejected.subject', :default => "Order Rejected")
    end
  
    def shipped(order)
      @order = order
      mail :from => Shoppe.settings.outbound_email_address, :to => order.email_address, :subject => I18n.t('shoppe.order_mailer.shipped.subject', :default => "Order Shipped")
    end

    def returned(order)
      @order = order
      mail :from => Shoppe.settings.outbound_email_address, :to => order.email_address, :subject => I18n.t('shoppe.order_mailer.returned.subject', :default => "Order Returned")
    end

  end
end
