module Spree
  class PaymentMethod::SisowBilling::Purchase
    def initialize(source)
      @status = source.status.downcase
    end

    def success?
      @status == "success"
    end

    def authorization
      nil
    end

    def to_s
      success? ? super : "Payment failed"
    end
  end
end
