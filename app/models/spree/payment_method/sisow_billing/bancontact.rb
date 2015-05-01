module Spree
  class PaymentMethod::SisowBilling
    class Bancontact < SisowPaymentMethod
      def payment_type
        "bancontact"
      end
    end
  end
end
