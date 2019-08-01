module Spree
  class PaymentMethod::SisowBilling
    class Creditcard < SisowPaymentMethod
      def payment_type
        "creditcard"
      end
    end
  end
end
