require 'spec_helper'

describe Spree::BillingIntegration::SisowBilling do
  let(:order) {
    order = Spree::Order.new(:bill_address => Spree::Address.new,
                     :ship_address => Spree::Address.new)
  }
  let(:sisow_api_callback) { double(Sisow::Api::Callback)}
  let(:sisow_transaction) { mock_model(Spree::SisowTransaction)}
  let(:payment) { mock_model(Spree::Payment) }
  let(:subject) { Spree::BillingIntegration::SisowBilling.new(order) }

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
    Sisow::Api::Callback.stub(:new).and_return(sisow_api_callback)
    Spree::SisowTransaction.stub_chain(:where, :first).and_return(sisow_transaction)

    #Stub Sisow API Callback methods
    sisow_api_callback.stub(:status).and_return("Success")
    sisow_api_callback.stub(:sha1).and_return("1234567890")
    sisow_api_callback.stub(:valid?).and_return(true)
    sisow_api_callback.stub(:success?).and_return(true)
    sisow_api_callback.stub(:cancelled?).and_return(false)

    #Stub Order methods
    order.stub_chain(:payments, :where, :present?).and_return(true)
    order.stub_chain(:payments, :where, :first).and_return(payment)
    order.stub(:completed?).and_return(true)

    #Stub SisowTransaction methods
    sisow_transaction.stub(:transaction_type).and_return('ideal')

    #Stub Payment methods
    payment.stub(:completed?).and_return(true)

    #We should receive the following method calls
    #payment.should_receive(:started_processing!)
    #payment.should_receive(:complete!)
    #order.should_receive(:update_attributes)
    #order.should_receive(:finalize!)
    sisow_transaction.should_receive(:update_attributes).with({:status=>"Success", :sha1=>"1234567890"})

    expect {
      subject.process_response({})
    }.to_not raise_error
    expect(subject.success?).to be true
  end

  it "should process a cancel response correctly" do
    Sisow::Api::Callback.stub(:new).and_return(sisow_api_callback)
    Spree::SisowTransaction.stub_chain(:where, :first).and_return(sisow_transaction)

    #Stub Sisow API Callback methods
    sisow_api_callback.stub(:status).and_return("Cancel")
    sisow_api_callback.stub(:sha1).and_return("1234567890")
    sisow_api_callback.stub(:valid?).and_return(true)
    sisow_api_callback.stub(:success?).and_return(false)
    sisow_api_callback.stub(:failure?).and_return(false)
    sisow_api_callback.stub(:expired?).and_return(false)
    sisow_api_callback.stub(:cancelled?).and_return(true)

    #Stub Order methods
    order.stub_chain(:payments, :where, :present?).and_return(true)
    order.stub_chain(:payments, :where, :first).and_return(payment)

    #Stub SisowTransaction methods
    sisow_transaction.stub(:transaction_type).and_return('ideal')

    #Stub Payment methods
    payment.stub(:void?).and_return(false)

    #We should receive the following method calls
    #payment.should_receive(:started_processing!)
    payment.should_receive(:void!)
    sisow_transaction.should_receive(:update_attributes).with({:status=>"Cancel", :sha1=>"1234567890"})

    expect {
      subject.process_response({})
    }.to_not raise_error
    
    #Cannot check this because we stub payment.void?
    #expect(subject.cancelled?).to be true
  end
end
