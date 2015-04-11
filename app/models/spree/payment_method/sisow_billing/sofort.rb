module Spree
  class PaymentMethod::SisowBilling
    class Sofort < SisowPaymentMethod
      def redirect_url(order, opts = {})
        sisow = PaymentMethod::SisowBilling.new(order)
        sisow.start_transaction('sofort', opts)
      end
    end
  end
end
