module Spree
  class PaymentMethod::SisowBilling::Bancontact < PaymentMethod::SisowBilling::SisowPaymentMethod
    def redirect_url(order, opts = {})
      sisow = PaymentMethod::SisowBilling.new(order)
      sisow.start_transaction('bancontact', opts)
    end
  end
end
