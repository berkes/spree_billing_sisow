require "spec_helper"

describe Spree::PaymentMethod::SisowBilling::SisowPaymentMethod, type: :model do
  it "should respond with false when calling payment_profiles_supported?" do
    expect(subject.payment_profiles_supported?).to be false
  end

  it "should respond with true when calling auto_capture?" do
    expect(subject.auto_capture?).to be true
  end

  describe "#purchase" do
    it "should initiate a new Purchase with source" do
      sisow_transaction = double("Spree::SisowTransaction", status: "Success")
      purchase_class = Spree::PaymentMethod::SisowBilling::Purchase
      expect(subject.purchase(0, sisow_transaction, {})).to be_a purchase_class
    end
  end
end
