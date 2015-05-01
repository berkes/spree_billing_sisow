require 'spec_helper'

feature 'callback' do
  let(:user) { create(:user) }
  let(:order) { OrderWalkthrough.up_to(:delivery) }
  let(:sisow_request_url) { 'http://www.sisow.nl/Sisow/iDeal/RestHandler.ashx/TransactionRequest' }
  let(:sisow_request_params) do
    { amount: '2000',
      callbackurl: "http://www.example.com/sisow/#{order.number}",
      cancelurl: "http://www.example.com/orders/#{order.number}/checkout/sisow_cancel",
      description: "Spree Test Store - Order: #{order.number}",
      issuerid: '99',
      merchantid: '2537407799',
      notifyurl: "http://www.example.com/sisow/#{order.number}",
      payment: 'ideal',
      purchaseid: order.number,
      returnurl: "http://www.example.com/orders/#{order.number}/checkout/sisow_return",
      shop_id: '',
      entrancecode: entrance_code,
      sha1: sha1}
  end

  let(:transaction_id) { 'TEST1337' }
  let(:entrance_code) { 'P1337K42' }
  let(:sha1) {
    Digest::SHA1.hexdigest(string = [
      transaction_id,
      entrance_code,
      'Success',
      Spree::Config.preferred_sisow_merchant_id,
      Spree::Config.preferred_sisow_merchant_key
    ].join)
  }

  before do
    ideal = Spree::PaymentMethod::SisowBilling::Ideal.create!(name: "iDeal")
    transaction = Spree::SisowTransaction.create!(
      transaction_id: transaction_id,
      entrance_code: entrance_code,
      status: 'pending',
      transaction_type: 'ideal'
    )
    order.payments.create!(
      amount: order.total,
      source: transaction,
      payment_method: ideal,
      state: 'checkout',
      number: entrance_code);
    order.state = "payment"

    stub_user_with_order(user, order)
  end

  context 'when sisow has not yet sent a success callback' do
    scenario 'I return at the return url' do
      visit "/orders/#{order.number}/checkout/sisow_return?trxid=#{transaction_id}&ec=#{entrance_code}&status=Success&sha1=#{sha1}"
      expect(page).to have_content "Your order has been processed successfully"
      expect(page).to have_content "Payment Information iDeal"
    end
  end

  context 'when sisow has sent a success callback' do
    scenario 'I return at the return url' do
      # Callback by Sisow servers
      visit "/sisow/#{order.number}?trxid=#{transaction_id}&ec=#{entrance_code}&status=Success&sha1=#{sha1}&notify=true&callback=true"
      expect(page.driver.response.status).to be 200

      # Returning visitor
      visit "/orders/#{order.number}/checkout/sisow_return?trxid=#{transaction_id}&ec=#{entrance_code}&status=Success&sha1=#{sha1}"
      expect(page).to have_content "Your order has been processed successfully"
      expect(page).to have_content "Payment Information iDeal"
    end
  end

  context 'when sisow has sent a success callback' do
    scenario 'I cancel my return to the shop' do
      # Callback by Sisow servers
      visit "/sisow/#{order.number}?trxid=#{transaction_id}&ec=#{entrance_code}&status=Success&sha1=#{sha1}&notify=true&callback=true"
      expect(page.driver.response.status).to be 200

      # TODO: Implement callback so that it finishes the order and the
      #       Payment: it is more likely that the callback succeeds then that
      #       the user is correctly redirected back.
      #       We should depend on the first and allow the latter. Now we do it the other
      #       way around.
      # order.reload
      # expect(order.state).to be 'finished'
      # expect(order.payments.first.state).to be 'checkout'
      expect(order.payments.first.source.status).to eq "Success"
    end
  end
end
