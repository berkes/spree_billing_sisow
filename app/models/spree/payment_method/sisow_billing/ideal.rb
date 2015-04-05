module Spree
  class PaymentMethod::SisowBilling::Ideal < PaymentMethod

    def payment_profiles_supported?
      false
    end

    def auto_capture?
      true
    end

    def purchase(amount, source, opts)
      if source.status.downcase == "success"
        Class.new do
          def success?; true; end
          def authorization; nil; end
        end.new
      else
        Class.new do
          def success?; false; end
          def authorization; nil; end
          def to_s
            "Payment failed"
          end
        end.new
      end
    end

    def redirect_url(order, opts = {})
      sisow = PaymentMethod::SisowBilling.new(order)
      sisow.start_transaction('ideal', opts)
    end

    def self.issuer_list
      PaymentMethod::SisowBilling.configure
      Sisow::Issuer.list
    end
  end 
end
