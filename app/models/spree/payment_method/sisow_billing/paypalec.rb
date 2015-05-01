module Spree
  class PaymentMethod::SisowBilling
    class Paypalec < SisowPaymentMethod
      def redirect_url(order, opts = {})
        sisow = PaymentMethod::SisowBilling.new(order)
        sisow.start_transaction('paypalec', opts)
      end
    end
  end
end
