require "spec_helper"

describe Spree::PaymentMethod::SisowBilling, type: :model do
  let(:order) do
    Spree::Order.new(:bill_address => Spree::Address.new,
                     :ship_address => Spree::Address.new)
  end
  let(:sisow_transaction) do
    mock_model(Spree::SisowTransaction, transaction_type: "ideal")
  end
  let(:payment) { mock_model(Spree::Payment) }
  let(:subject) { Spree::PaymentMethod::SisowBilling.new(order) }
  let(:sisow_api_callback) do
    double(Sisow::Api::Callback,
           status: "Any Status",
           sha1: "1234567890",
           valid?: false,
           cancelled?: false)
  end
  context "when payment is not initialized" do
    it "should respond to .success? with false" do
      expect(subject.success?).to be false
    end

    it "should respond to .failed? with false" do
      expect(subject.failed?).to be true
    end

    it "should respond to .cancelled? with false" do
      expect(subject.cancelled?).to be false
    end
  end

  describe "#start_transaction" do
    it "should return the correct payment provider" do
      expect(subject.send(:payment_provider, "ideal", {})).to be_kind_of(Sisow::IdealPayment)
      expect(subject.send(:payment_provider, "sofort", {})).to be_kind_of(Sisow::SofortPayment)
      expect(subject.send(:payment_provider, "bancontact", {})).to be_kind_of(Sisow::BancontactPayment)
      expect{
        subject.send(:payment_provider, "fakebank", {})
      }.to raise_error
    end
  end

  describe "#process_response" do
    before do
      allow(Sisow::Api::Callback).to receive(:new).and_return(sisow_api_callback)
      allow(Spree::SisowTransaction).to receive_message_chain(:where, :first).and_return(sisow_transaction)

      allow(order).to receive_message_chain(:payments, :where, :present?).and_return(true)
      allow(order).to receive_message_chain(:payments, :where, :first).and_return(payment)
    end

    context "when callback is valid" do
      before { allow(sisow_api_callback).to receive(:valid?).and_return(true) }

      it "updates sisow transaction with a transaction sha" do
        expect(sisow_transaction).to receive(:update_attributes).with(
          hash_including(sha1: "1234567890"))
        subject.process_response({})
      end

      context "when response is success" do
        before do
          allow(sisow_api_callback).to receive(:status).and_return("Success")
          allow(payment).to receive(:completed?).and_return(true)
        end

        it "updates sisow transaction with a transaction sha" do
          expect(sisow_transaction).to receive(:update_attributes).with(
            hash_including(sha1: "1234567890"))
          subject.process_response({})
        end

        it "updates sisow transaction with status Success" do
          expect(sisow_transaction).to receive(:update_attributes).with(
            hash_including(status: "Success"))
          subject.process_response({})
        end
      end

      context "when response is failure" do
        before do
          allow(sisow_api_callback).to receive(:status).and_return("Cancel")
          allow(sisow_api_callback).to receive(:cancelled?).and_return(true)

          allow(payment).to receive(:void?).and_return(false)
          allow(payment).to receive(:void!)
          allow(sisow_transaction).to receive(:update_attributes)
        end

        it "voids payment" do
          expect(payment).to receive(:void!)
          subject.process_response({})
        end

        it "updates sisow transaction with a transaction sha" do
          expect(sisow_transaction).to receive(:update_attributes).with(
            hash_including(sha1: "1234567890"))
          subject.process_response({})
        end

        it "updates sisow transaction with status Cancel" do
          expect(sisow_transaction).to receive(:update_attributes).with(
            hash_including(status: "Cancel"))
          subject.process_response({})
        end
      end
    end
  end

  describe "#success?" do
    context "with payment" do
      # TODO: change the implementation to allow outsiders to set payments too.
      before { subject.instance_variable_set(:@payment, payment) }
      context "which is completed" do
        before { allow(payment).to receive(:completed?).and_return(true) }
        it { expect(subject.success?).to be false }

        context "when order is also completed" do
          before { allow(order).to receive(:completed?).and_return(true) }
          it { expect(subject.success?).to be true }
        end
      end
    end

    context "without payment" do
      it { expect(subject.success?).to be false }
    end
  end
end
