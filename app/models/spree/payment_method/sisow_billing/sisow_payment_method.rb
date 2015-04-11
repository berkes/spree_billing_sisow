module Spree
  class PaymentMethod::SisowBilling::SisowPaymentMethod < PaymentMethod
    def payment_profiles_supported?
      false
    end

    def auto_capture?
      true
    end

    def purchase(_amount, source, _opts)
      PaymentMethod::SisowBilling::Purchase.new(source)
    end
  end
end
