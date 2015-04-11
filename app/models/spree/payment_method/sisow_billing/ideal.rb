module Spree
  class PaymentMethod::SisowBilling::Ideal < PaymentMethod::SisowBilling::SisowPaymentMethod
    def redirect_url(order, opts = {})
      sisow = PaymentMethod::SisowBilling.new(order)
      sisow.start_transaction('ideal', opts)
    end

    def self.issuer_list
      PaymentMethod::SisowBilling.configure
      Sisow::Issuer.list
    end
  end 
end
