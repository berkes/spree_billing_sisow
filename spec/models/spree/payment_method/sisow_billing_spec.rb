require "spec_helper"

shared_examples 'sisow payment' do |transaction_type, sisow_class, billing_class|
  before do
    allow(sisow_class).to receive(:new).and_return(sisow_payment)
    allow(sisow_transaction).to receive(:transaction_type).and_return(transaction_type)
  end

  it "creates a sisow transaction with transaction_type #{transaction_type}" do
    expect(Spree::SisowTransaction).to receive(:create).
      with(hash_including(transaction_type: transaction_type))
    subject.start_transaction(transaction_type)
  end

  describe "creates a payment" do
    it "sets first SisowBilling::Ideal PaymentMethod as payment_method" do
      payment_method = double(:payment_method)
      expect(Spree::PaymentMethod).to receive(:where).
        with(type: billing_class.to_s).
        and_return([payment_method])

      expect(payments_arel).to receive(:create).
        with(hash_including(payment_method: payment_method))
      subject.start_transaction(transaction_type)
    end
  end

  describe "initializes a #{sisow_class}" do
    it "passes in options for start_transaction" do
      expect(sisow_class).to receive(:new).with(hash_including(option: :value))
      subject.start_transaction(transaction_type, option: :value)
    end

    it "passes in description with the store and order-number" do
      store = double(:store, name: 'Example Shop')
      allow(Spree::Store).to receive(:current).and_return(store)
      expect(sisow_class).to receive(:new).
        with(hash_including(description: "Example Shop - Order: O1337"))
      subject.start_transaction(transaction_type)
    end

    it "passes the order-number as purchase_id" do
      expect(sisow_class).to receive(:new).
        with(hash_including(purchase_id: 'O1337'))
      subject.start_transaction(transaction_type)
    end

    it "passes the order-total in cents as amount" do
      expect(sisow_class).to receive(:new).
        with(hash_including(amount: 1337))
      subject.start_transaction(transaction_type)
    end

    it "passes payment number as entrance_code" do
      expect(sisow_class).to receive(:new).
        with(hash_including(entrance_code: 'P1337'))
      subject.start_transaction(transaction_type)
    end
  end

  it "sets transaction_id and entrance_code" do
    expect(sisow_transaction).to receive(:update_attributes).
      with({transaction_id: "ABC", entrance_code: "P1337"})

    subject.start_transaction(transaction_type)
  end
end

describe Spree::PaymentMethod::SisowBilling, type: :model do
  let(:order) { double(:order, number: 'O1337', total: 13.37) }
  let(:sisow_transaction) do
    double(:sisow_transaction,
           transaction_type: "ideal",
           update: nil,
           update_attributes: nil)
  end
  let(:payment) { mock_model(Spree::Payment, number: 'P1337') }
  let(:subject) { Spree::PaymentMethod::SisowBilling.new(order) }
  let(:sisow_api_callback) do
    double(Sisow::Api::Callback,
           status: "Any Status",
           sha1: "1234567890",
           valid?: false,
           cancelled?: false)
  end
  let (:payments_arel) { double(:payments) }

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
    let(:sisow_payment) do
      double(:sisow_payment,
             transaction_id: 'ABC',
             payment_url: '')
    end

    before do
      allow(order).to receive(:payments).and_return(payments_arel)
      allow(payments_arel).to receive(:create).and_return(payment)

      allow(Spree::SisowTransaction).to receive(:create).and_return(sisow_transaction)
      allow(Sisow::Payment).to receive(:new).and_return(sisow_payment)
    end

    it "returns payment_url" do
      url = "http://example.com"
      allow(sisow_payment).to receive(:payment_url).and_return(url)
      # Could be any payment method, using ideal to avoid unrelated errors
      expect(subject.start_transaction("ideal")).to eq url
    end

    it "creates a sisow transaction with status pending" do
      expect(Spree::SisowTransaction).to receive(:create).
        with(hash_including(status: "pending"))
      subject.start_transaction("ideal")
    end

    describe "creates a payment" do
      it "sets order total as amount" do
        expect(payments_arel).to receive(:create).
          with(hash_including(amount: 13.37))
        subject.start_transaction("ideal")
      end

      it "sets sisow_transaction as source" do
        expect(payments_arel).to receive(:create).
          with(hash_including(source: sisow_transaction))
        subject.start_transaction("ideal")
      end
    end

    context "when transaction_type is ideal" do
      include_examples "sisow payment",
        "ideal",
        Sisow::IdealPayment,
        Spree::PaymentMethod::SisowBilling::Ideal
    end

    context 'when transaction_type is sofort' do
      include_examples "sisow payment",
        "sofort",
        Sisow::SofortPayment,
        Spree::PaymentMethod::SisowBilling::Sofort
    end

    context 'when transaction_type is bancontact' do
      include_examples "sisow payment",
        "bancontact",
        Sisow::BancontactPayment,
        Spree::PaymentMethod::SisowBilling::Bancontact
    end

    context 'when transaction_type is paypalec' do
      include_examples "sisow payment",
        "paypalec",
        Sisow::PaypalPayment,
        Spree::PaymentMethod::SisowBilling::Paypalec
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
        before do
          allow(payment).to receive(:completed?).and_return(true)
          allow(order).to receive(:completed?).and_return(false)
        end

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
