require 'spec_helper'

describe Spree::PaymentMethod::SisowBilling::Paypalec do
  # TODO: Turn this into an actual unit-test. Now it acts as integration
  #       test, but looks like a unit-test. All the "redirect_url" method does
  #       is call a method on a new Payment.

  let(:order) { double("Spree::Order", total: 3, number: order_number) }
  let(:payment){ double("Spree::Payment", number: payment_number) }
  let(:payment_number) { 'TEST1337' }
  let(:order_number) { 'P1337K42' }
  let(:amount) { 300 }
  let(:merchant_id) { Spree::Config.sisow_merchant_id }
  let(:merchant_key) { Spree::Config.sisow_merchant_key }
  let(:sha1) {
    Digest::SHA1.hexdigest([
      order_number,
      payment_number,
      amount,
      merchant_id,
      merchant_key
    ].join)
  }
  let(:options) {
    {
      return_url: 'http://www.example.com/return',
      cancel_url: 'http://www.example.com/cancel',
      notify_url: 'http://www.example.com/notify',
    }
  }

  # Webmock request files
  let(:sisow_redirect_url) { File.new("spec/webmock_files/paypal_redirect_url_output") }

  before do
    allow(Spree::Store).to receive(:current).and_return double(Spree::Store, name: "Spree Demo Site")
    allow(Spree::Config).to receive(:sisow_merchant_id).and_return merchant_id
    allow(Spree::Config).to receive(:sisow_merchant_key).and_return merchant_key

    allow(order).to receive_message_chain(:payments, :create).and_return(payment)

    stub_request(:get, "http://www.sisow.nl/Sisow/iDeal/RestHandler.ashx/TransactionRequest")
      .with(query: {
        "amount" => "300",
        "callbackurl" => "",
        "cancelurl" => "http://www.example.com/cancel",
        "description" => "Spree Demo Site - Order: #{order_number}",
        "entrancecode" => payment_number,
        "issuerid" => "99",
        "merchantid" => merchant_id,
        "notifyurl" => "http://www.example.com/notify",
        "payment" => "paypalec",
        "purchaseid" => order_number,
        "returnurl" => "http://www.example.com/return",
        "sha1" => sha1,
        "shop_id" => "",
        "test" => "true"})
      .to_return(sisow_redirect_url)
  end


  it "should return a payment URL to the Sisow API" do
    expect(subject.redirect_url(order, options)).to match(/https:\/\/www\.sisow\.nl\/Sisow\/iDeal\/Simulator\.aspx/)
  end
end
