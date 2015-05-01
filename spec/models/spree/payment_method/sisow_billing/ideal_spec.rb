require 'spec_helper'

describe Spree::PaymentMethod::SisowBilling::Ideal, type: :model do
  let(:order) { double("Spree::Order") }
  let(:payment){ double("Spree::Payment") }

  let(:options) {
    {
      return_url: 'http://www.example.com',
      cancel_url: 'http://www.example.com',
      notify_url: 'http://www.example.com',
      issuer_id: 99
    }
  }

  before do
    allow(Spree::PaymentMethod).to receive(:find_by!).with(type: subject.class.to_s).and_return(subject)
  end

  it "should return the issuer list from retrieved from Sisow" do
    expect do
      stub_request(:get, "http://www.sisow.nl/Sisow/iDeal/RestHandler.ashx/DirectoryRequest?merchantid=2537407799&test=true")
        .to_return(stored_response("ideal_issuer_output"))
    end.not_to raise_error
    expect(Spree::PaymentMethod::SisowBilling::Ideal.issuer_list.length).to be >= 1
  end

  it "should return a payment URL to the Sisow API" do
    allow(Spree::Store).to receive(:current).and_return double(Spree::Store, name: "Spree Demo Site")
    stub_request(:get, "http://www.sisow.nl/Sisow/iDeal/RestHandler.ashx/TransactionRequest?amount=300&callbackurl=&cancelurl=http://www.example.com&description=Spree%20Demo%20Site%20-%20Order:%20O12345678&entrancecode=R12345678&issuerid=99&merchantid=2537407799&notifyurl=http://www.example.com&payment=ideal&purchaseid=O12345678&returnurl=http://www.example.com&sha1=876b2c3c20b56f34cad4a9108bd42dd16885baeb&shop_id=&test=true")
      .to_return(stored_response("ideal_redirect_url_output"))
    allow(payment).to receive(:number) { "R12345678" }
    allow(order).to receive(:total) { 3 }
    allow(order).to receive(:number) { "O12345678" }
    allow(order).to receive_message_chain(:payments, :create).and_return(payment)

    #payment.should_receive(:started_processing!)
    #payment.should_receive(:pend!)

    expect(subject.redirect_url(order, options)).to match(/https:\/\/www\.sisow\.nl\/Sisow\/iDeal\/Simulator\.aspx/)
  end
end
