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

    def redirect_url(order, opts = {})
      sisow = PaymentMethod::SisowBilling.new(order)
      sisow.start_transaction(payment_type, opts)
    end

    def payment_type
      raise "this method should be overriden and return the type of payment"
    end
  end
end
