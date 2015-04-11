require 'spec_helper'

describe Spree::CheckoutController, type: :controller do
  let(:token) { 'some_token' }
  let(:user) { stub_model(Spree::LegacyUser) }
  let(:order) { FactoryGirl.create(:order_with_totals) }
  let(:payment_method) { double(Spree::PaymentMethod::SisowBilling) }

  before do
    controller.stub :try_spree_current_user => user
    controller.stub :current_order => order
    controller.stub :handle_sisow_response => payment_method
  end

  #it "should handle the sisow success response and set the flash to thank_you_for_your_order" do
  #  Spree::PaymentMethod::SisowBilling.stub(:new).and_return(sisow_billing)
  #  sisow_billing.stub(:process_response)
  #  sisow_billing.stub(:failed?).and_return(false)
  #  sisow_billing.should_receive(:succes?).and_return(true)
  #  spree_post :sisow_return
  #
  #  expect(flash[:notice]).to be false
  #end
  #
  #it "should handle the sisow cancel response and set the flash to payment_has_been_cancelled" do
  #
  #end
  #
  #it "should handle a garbage sisow response and set the flash to payment_processing_failed" do
  #  billing_integration.should_receive(:new)
  #  billing_integration.should_receive(:failed?).and_return(true)
  #  spree_post :sisow_return
  #  expect(flash[:notice]).to be false
  #end

end
