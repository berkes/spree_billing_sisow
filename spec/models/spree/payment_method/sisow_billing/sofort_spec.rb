require 'spec_helper'

describe Spree::PaymentMethod::SisowBilling::Sofort, type: :model do
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

  #Webmock request file
  let(:sisow_redirect_url) { File.new("spec/webmock_files/sofort_redirect_url_output") }

  it "should return a payment URL to the Sisow API" do
    stub_request(:get, "http://www.sisow.nl/Sisow/iDeal/RestHandler.ashx/TransactionRequest?amount=300&callbackurl=&cancelurl=http://www.example.com&description=Spree%20Demo%20Site%20-%20Order:%20O12345678&entrancecode=R12345678&issuerid=99&merchantid=2537407799&notifyurl=http://www.example.com&payment=sofort&purchaseid=O12345678&returnurl=http://www.example.com&sha1=876b2c3c20b56f34cad4a9108bd42dd16885baeb&shop_id=&test=true").to_return(sisow_redirect_url)
    allow(payment).to receive(:number) { "R12345678" }
    allow(order).to receive(:total) { 3 }
    allow(order).to receive(:number) { "O12345678" }
    allow(order).to receive_message_chain(:payments, :create).and_return(payment)
    allow(Spree::Store).to receive(:current).and_return double(Spree::Store, name: "Spree Demo Site")

    #payment.should_receive(:started_processing!)
    #payment.should_receive(:pend!)

    expect(subject.redirect_url(order, options)).to match(/https:\/\/www\.sisow\.nl\/Sisow\/iDeal\/Simulator\.aspx/)
  end
end
