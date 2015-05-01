module Spree
  class PaymentMethod::SisowBilling
    class Sofort < SisowPaymentMethod
      def payment_type
        "sofort"
      end
    end
  end
end
