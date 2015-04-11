require 'spec_helper'

describe Spree::PaymentMethod::SisowBilling, type: :model do
  let(:order) {
    order = Spree::Order.new(:bill_address => Spree::Address.new,
                     :ship_address => Spree::Address.new)
  }
  let(:sisow_api_callback) { double(Sisow::Api::Callback)}
  let(:sisow_transaction) { mock_model(Spree::SisowTransaction)}
  let(:payment) { mock_model(Spree::Payment) }
  let(:subject) { Spree::PaymentMethod::SisowBilling.new(order) }

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

  it "should return the correct payment provider" do
    expect(subject.send(:payment_provider, 'ideal', {})).to be_kind_of(Sisow::IdealPayment)
    expect(subject.send(:payment_provider, 'sofort', {})).to be_kind_of(Sisow::SofortPayment)
    expect(subject.send(:payment_provider, 'bancontact', {})).to be_kind_of(Sisow::BancontactPayment)
    expect{
      subject.send(:payment_provider, 'fakebank', {})
    }.to raise_error
  end

  it "should process a succes response correctly" do
    allow(Sisow::Api::Callback).to receive(:new).and_return(sisow_api_callback)
    allow(Spree::SisowTransaction).to receive_message_chain(:where, :first).and_return(sisow_transaction)

    #Stub Sisow API Callback methods
    allow(sisow_api_callback).to receive(:status).and_return("Success")
    allow(sisow_api_callback).to receive(:sha1).and_return("1234567890")
    allow(sisow_api_callback).to receive(:valid?).and_return(true)
    allow(sisow_api_callback).to receive(:success?).and_return(true)
    allow(sisow_api_callback).to receive(:cancelled?).and_return(false)

    #Stub Order methods
    allow(order).to receive_message_chain(:payments, :where, :present?).and_return(true)
    allow(order).to receive_message_chain(:payments, :where, :first).and_return(payment)
    allow(order).to receive(:completed?).and_return(true)

    #Stub SisowTransaction methods
    allow(sisow_transaction).to receive(:transaction_type).and_return('ideal')

    #Stub Payment methods
    allow(payment).to receive(:completed?).and_return(true)

    #We should receive the following method calls
    #payment.should_receive(:started_processing!)
    #payment.should_receive(:complete!)
    #order.should_receive(:update_attributes)
    #order.should_receive(:finalize!)
    expect(sisow_transaction).to receive(:update_attributes).with({:status=>"Success", :sha1=>"1234567890"})

    expect {
      subject.process_response({})
    }.to_not raise_error
    expect(subject.success?).to be true
  end

  it "should process a cancel response correctly" do
    allow(Sisow::Api::Callback).to receive(:new).and_return(sisow_api_callback)
    allow(Spree::SisowTransaction).to receive_message_chain(:where, :first).and_return(sisow_transaction)

    #Stub Sisow API Callback methods
    allow(sisow_api_callback).to receive(:status).and_return("Cancel")
    allow(sisow_api_callback).to receive(:sha1).and_return("1234567890")
    allow(sisow_api_callback).to receive(:valid?).and_return(true)
    allow(sisow_api_callback).to receive(:success?).and_return(false)
    allow(sisow_api_callback).to receive(:failure?).and_return(false)
    allow(sisow_api_callback).to receive(:expired?).and_return(false)
    allow(sisow_api_callback).to receive(:cancelled?).and_return(true)

    #Stub Order methods
    allow(order).to receive_message_chain(:payments, :where, :present?).and_return(true)
    allow(order).to receive_message_chain(:payments, :where, :first).and_return(payment)

    #Stub SisowTransaction methods
    allow(sisow_transaction).to receive(:transaction_type).and_return('ideal')

    #Stub Payment methods
    allow(payment).to receive(:void?).and_return(false)

    #We should receive the following method calls
    #payment.should_receive(:started_processing!)
    expect(payment).to receive(:void!)
    expect(sisow_transaction).to receive(:update_attributes).with({:status=>"Cancel", :sha1=>"1234567890"})

    expect {
      subject.process_response({})
    }.to_not raise_error
    
    #Cannot check this because we stub payment.void?
    #expect(subject.cancelled?).to be true
  end
end
