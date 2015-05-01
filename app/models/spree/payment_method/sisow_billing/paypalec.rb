module Spree
  class PaymentMethod::SisowBilling
    class Paypalec < SisowPaymentMethod
      def payment_type
        "paypalec"
      end
    end
  end
end
