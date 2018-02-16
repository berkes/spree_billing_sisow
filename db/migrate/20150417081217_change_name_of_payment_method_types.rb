class ChangeNameOfPaymentMethodTypes < ActiveRecord::Migration[5.0]
  def up
    name_maps.each do |old, new|
      Spree::PaymentMethod.where(type: old).update_all(type: new)
    end
  end

  def down
    name_maps.each do |old, new|
      Spree::PaymentMethod.where(type: new).update_all(type: old)
    end
  end

  private
  def name_maps
    {
     'Spree::BillingIntegration::SisowBilling::Ideal' => 'Spree::PaymentMethod::SisowBilling::Ideal',
     'Spree::BillingIntegration::SisowBilling::Bancontact' => 'Spree::PaymentMethod::SisowBilling::Bancontact',
     'Spree::BillingIntegration::SisowBilling::Sofort' => 'Spree::PaymentMethod::SisowBilling::Sofort'
    }
  end
end
