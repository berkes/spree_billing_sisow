require "spec_helper"

describe Spree::PaymentMethod::SisowBilling::SisowPaymentMethod, type: :model do
  subject { Spree::PaymentMethod::SisowBilling::Purchase.new(source) }
  let(:source) { double("Spree::SisowTransaction", status: "") }

  it { expect(subject.authorization).to be_nil }

  context "source status is Success" do
    before { allow(source).to receive(:status).and_return("Success") }
    it { expect(subject.success?).to be true }
    it { expect(subject.to_s).to match "Purchase" }
  end

  context "source status is expired" do
    before { allow(source).to receive(:status).and_return("expired") }
    it { expect(subject.success?).to be false }
    it { expect(subject.to_s).to eq "Payment failed" }
  end
end
