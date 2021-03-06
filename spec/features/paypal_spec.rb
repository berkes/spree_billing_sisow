# frozen_string_literal: true

require "spec_helper"

feature "paypal checkout" do
  let(:user) { create(:user) }
  let(:order) { OrderWalkthrough.up_to(:payment) }
  let(:sisow_request_url) do
    "http://www.sisow.nl/Sisow/iDeal/RestHandler.ashx/TransactionRequest"
  end

  before do
    stub_user_with_order(user, order)

    stub_request(:get, sisow_request_url).
      with(query: hash_including(sisow_request_params)).
      to_return(redirect_url_response)
  end

  context "site has has paymentmethod Paypal" do
    let(:paypal) do
      Spree::PaymentMethod::SisowBilling::Paypalec.create!(name: "Paypal")
    end
    let(:redirect_url_response) do
      stored_response("paypal_redirect_url_output")
    end
    let(:sisow_request_params) do
      { amount: "2999",
        callbackurl: "http://www.example.com/sisow/#{order.number}",
        cancelurl: "http://www.example.com/orders/#{order.number}/checkout/sisow_cancel",
        description: "Spree Test Store - Order: #{order.number}",
        merchantid: "2537407799",
        notifyurl: "http://www.example.com/sisow/#{order.number}",
        payment: "paypalec",
        purchaseid: order.number,
        returnurl: "http://www.example.com/orders/#{order.number}/checkout/sisow_return",
        shop_id: '' }
    end

    before do
      allow(order).to receive_messages(available_payment_methods: [paypal])

      visit spree.checkout_state_path(:payment)

      # Disable redirects, or else we'll be redirected to the actual sisow page
      # which cannot be handled by RackTest but is not a good idea either.
      # We just want to know that we got the right response.
      Capybara.page.driver.options[:follow_redirects] = false
    end

    scenario "I choose the only payment option Paypal, and Sisow and redirects me there" do
      click_button "Save and Continue"
      expect(WebMock).to have_requested(:get, sisow_request_url).with(query: hash_including(sisow_request_params))
      response = page.driver.response
      expect(response.status).to be 302
      expect(response.headers["Location"]).to match(%r(https://www\.sisow\.nl/Sisow/iDeal/Simulator\.aspx\?merchantid=2537407799&txid=\w*&sha1=\w*))
    end
  end

  after do
    Capybara.page.driver.options[:follow_redirects] = true
  end
end
