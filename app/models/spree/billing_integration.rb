class Spree::BillingIntegration
  class SisowBilling
    class Method < ::Spree::PaymentMethod
      class << self
        extend Gem::Deprecate
        deprecate :new, "PaymentMethod", 2016, 10
      end
    end

    class Bancontact < Method
      def self.new(*attrs)
        super
        ::Spree::PaymentMethod::SisowBilling::Bancontact.new(*attrs)
      end
    end

    class Creditcard < Method
      def self.new(*attrs)
        super
        ::Spree::PaymentMethod::SisowBilling::Creditcard.new(*attrs)
      end
    end

    class Ideal < Method
      def self.new(*attrs)
        super
        ::Spree::PaymentMethod::SisowBilling::Ideal.new(*attrs)
      end
    end

    class Sofort < Method
      def self.new(*attrs)
        super
        ::Spree::PaymentMethod::SisowBilling::Sofort.new(*attrs)
      end
    end
  end
end
