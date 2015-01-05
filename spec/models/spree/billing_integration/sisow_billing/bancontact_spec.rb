require 'spec_helper'

describe Spree::BillingIntegration::SisowBilling::Bancontact do
  let(:subject) { Spree::BillingIntegration::SisowBilling::Bancontact.new }
  let(:order) { double("Spree::Order") }
  let(:sisow_transaction) { double("Spree::SisowTransaction") }
  let(:payment){ double("Spree::Payment") }

  let(:options) {
    {
        return_url: 'http://www.example.com',
        cancel_url: 'http://www.example.com',
        notify_url: 'http://www.example.com',
        issuer_id: 99
    }
  }

  #Webmock request file
  let(:sisow_redirect_url) { File.new("spec/webmock_files/bancontact_redirect_url_output") }

  it "should return a payment URL to the Sisow API" do

    allow(Spree::Store).to receive(:current).and_return double(Spree::Store, name: "Spree Demo Site")
    stub_request(:get, "http://www.sisow.nl/Sisow/iDeal/RestHandler.ashx/TransactionRequest?amount=300&callbackurl=&cancelurl=http://www.example.com&description=Spree%20Demo%20Site%20-%20Order:%20O12345678&entrancecode=R12345678&issuerid=99&merchantid=2537407799&notifyurl=http://www.example.com&payment=mistercash&purchaseid=O12345678&returnurl=http://www.example.com&sha1=876b2c3c20b56f34cad4a9108bd42dd16885baeb&shop_id=&test=true").to_return(sisow_redirect_url)
    payment.stub(:identifier) { "R12345678" }
    order.stub(:total) { 3 }
    order.stub(:number) { "O12345678" }
    order.stub_chain(:payments, :create).and_return(payment)

    #payment.should_receive(:started_processing!)
    #payment.should_receive(:pend!)

    expect(subject.redirect_url(order, options)).to match(/https:\/\/www\.sisow\.nl\/Sisow\/iDeal\/Simulator\.aspx/)
  end

  it "should respond with false when calling payment_profiles_supported?" do
    expect(subject.payment_profiles_supported?).to be_false
  end

  it "should respond with true when calling auto_capture?" do
    expect(subject.auto_capture?).to be_true
  end

  it "should respond with true when the transaction was successfull" do
    sisow_transaction.stub_chain(:status, :downcase).and_return('success')
    expect(subject.purchase('123', sisow_transaction, {}).success?).to be_true
  end

  it "should respond with false when the transaction was unsuccessfull" do
    sisow_transaction.stub_chain(:status, :downcase).and_return('expired')
    expect(subject.purchase('123', sisow_transaction, {}).success?).to be_false
  end
end
