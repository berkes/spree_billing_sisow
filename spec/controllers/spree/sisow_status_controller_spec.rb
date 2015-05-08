require 'spec_helper'

describe Spree::SisowStatusController, type: :controller do
  let(:payments) { Spree::Payment.none }
  let(:order) do
    mock_model(Spree::Order,
               payments: payments,
               next!: true,
               complete?: false)
  end
  let(:payment_method) { double(Spree::PaymentMethod::SisowBilling) }
  let(:params) do
    {
        "order_id" => "O12345678",
        "trxid" => "12345",
        "ec" => "54321",
        "status" => "Success",
        "sha1" => "1234567890"
    }
  end

  before do
    allow(Spree::Order).to receive(:find_by_number!).
      with("O12345678").
      and_return(order)
  end

  it "should update the transaction status" do
    test_params = params.clone
    test_params.delete(:use_route)
    test_params.merge!({"controller" => "spree/sisow_status", "action"=>"update"})
    expect(payment_method).to receive(:process_response).with(test_params)

    allow(Spree::PaymentMethod::SisowBilling).to receive(:new).and_return(payment_method)

    spree_post :update, params
  end

  context "order has not been finished by returning customer" do
    it "should finish the order" do
      expect(order).to receive(:next!)
      spree_post :update, params
    end
  end

  context "order has aldready been finished by returning customer" do
    before { allow(order).to receive(:complete?).and_return true }
    it "should not finish the order again" do
      expect(order).not_to receive(:next!)
      spree_post :update, params
    end
  end

  context "confirming a none-existing order" do
    before do
      allow(Spree::Order).to receive(:find_by_number!).with("O12345678").and_raise(ActiveRecord::RecordNotFound)
    end

    it "should log an error" do
      # Somehow in our spree, Logger is not defined on Rails but on ActionController.
      expect(ActionController::Base.logger).to receive(:error).with(/ERROR:.*\(O12345678\) not found/)
      spree_post :update, params
    end

    it "should return HTTP status code 500" do
      spree_post :update, params
      expect(response.status).to eq 500
    end
  end
end
