require "spec_helper"

feature "Administer" do
  context "as an admin" do
    stub_authorization!

    scenario "I want to browse to the sisow settings page" do
      # Reload Deface, else it won"t register our overrides.
      Rails.application.config.deface.overrides.load_all Rails.application
      visit spree.admin_path
      click_link "Sisow configuration"
      expect(page.find("h1")).to have_content "Sisow configuration"
    end

    context "when on the admin page" do
      before(:each) do
        visit spree.edit_admin_sisow_path
      end

      scenario "I want to provide the Sisow API-credentials" do
        within_fieldset "Identification settings" do
          fill_in "Merchant ID", with: "ABC"
          fill_in "Merchant Key", with: "DEF"
        end
        click_button "Update"

        expect(page).to have_content "Sisow settings updated"
        expect(page).to have_field("Merchant ID", with: "ABC")
        expect(page).to have_field("Merchant Key", with: "DEF")
      end

      scenario "I want to change environment" do
        expect(page).to have_checked_field "Test mode"
        expect(page).to have_unchecked_field "Debug mode"

        within_fieldset "Environment settings" do
          uncheck "Test mode"
          check "Debug mode"
        end
        click_button "Update"

        expect(page).to have_content "Sisow settings updated"
        expect(page).to have_unchecked_field "Test mode"
        expect(page).to have_checked_field "Debug mode"
      end
    end

    context "initialiate payments in backend" do
      let(:user) { create(:user) }
      let(:order) { OrderWalkthrough.up_to(:delivery) }
      let(:sisow_request_url) do
        "http://www.sisow.nl/Sisow/iDeal/RestHandler.ashx/TransactionRequest"
      end
      let(:redirect_url_response) { stored_response("ideal_redirect_url_output") }
      let(:sisow_request_params) do
        { amount: "2999",
          callbackurl: "http://www.example.com/sisow/#{order.number}",
          cancelurl: "http://www.example.com/orders/#{order.number}/checkout/sisow_cancel",
          description: "Spree Test Store - Order: #{order.number}",
          issuerid: "09", # Triodos Bank
          merchantid: '2537407799',
          notifyurl: "http://www.example.com/sisow/#{order.number}",
          payment: "ideal",
          purchaseid: order.number,
          returnurl: "http://www.example.com/orders/#{order.number}/checkout/sisow_return",
          shop_id: "" }
      end

      before do
        stub_user_with_order(user, order)

        stub_request(:get, sisow_request_url).
          with(query: hash_including(sisow_request_params)).
          to_return(redirect_url_response)

        visit spree.admin_orders_path
        uncheck "Only show complete orders"
        click_button "Filter Results"
      end

      it "can pay with iDeal" do
        Spree::PaymentMethod::SisowBilling::Ideal.create!(name: "iDeal")

        click_link order.number
        click_link "Payments"
        choose "iDeal"
        click_button "Update"

        # We need to fix this bug.
        expect(page).to have_content("Source can't be blank")
      end

      it "can pay with creditcard" do
        Spree::PaymentMethod::SisowBilling::Creditcard.create!(name: "CC")

        click_link order.number
        click_link "Payments"
        choose "CC"
        click_button "Update"

        # We need to fix this bug.
        expect(page).to have_content("Source can't be blank")
      end
    end
  end
end
