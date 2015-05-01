module Spree
  class PaymentMethod::SisowBilling
    class Ideal < SisowPaymentMethod
      def self.issuer_list
        PaymentMethod::SisowBilling.configure
        Sisow::Issuer.list
      end

      def payment_type
        "ideal"
      end
    end
  end
end
