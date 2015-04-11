require 'spec_helper'

describe Spree::PaymentMethod::SisowBilling::SisowPaymentMethod, type: :model do
  let(:sisow_transaction) { double("Spree::SisowTransaction") }

  it "should respond with false when calling payment_profiles_supported?" do
    expect(subject.payment_profiles_supported?).to be false
  end

  it "should respond with true when calling auto_capture?" do
    expect(subject.auto_capture?).to be true
  end

  it "should respond with true when the transaction was successfull" do
    allow(sisow_transaction).to receive_message_chain(:status, :downcase).and_return('success')
    expect(subject.purchase('123', sisow_transaction, {}).success?).to be true
  end

  it "should respond with false when the transaction was unsuccessfull" do
    allow(sisow_transaction).to receive_message_chain(:status, :downcase).and_return('expired')
    expect(subject.purchase('123', sisow_transaction, {}).success?).to be false
  end
end
