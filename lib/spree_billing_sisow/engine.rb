module SpreeBillingSisow
  class Engine < Rails::Engine
    require 'spree/core'
    require 'sisow'
    isolate_namespace Spree
    engine_name 'spree_billing_sisow'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc

    initializer "spree_billing_sisow.register.payment_methods", :after => 'spree.register.payment_methods' do |app|
      app.config.spree.payment_methods += [
          Spree::PaymentMethod::SisowBilling::Ideal,
          Spree::PaymentMethod::SisowBilling::Bancontact,
          Spree::PaymentMethod::SisowBilling::Sofort
      ]
    end
  end
end
