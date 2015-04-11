require 'spec_helper'

feature 'Administer' do
  context 'as an admin' do
    stub_authorization!

    scenario 'I want to browse to the sisow settings page' do
      visit spree.admin_path
      click_link 'Sisow settings'
      expect(page.find('h1')).to have_content 'Sisow configuration'
    end

    context 'when on the admin page' do
      before(:each) do
        visit spree.edit_admin_sisow_path
      end

      scenario 'I want to provide the Sisow API-credentials' do
        within_fieldset 'Identification settings' do
          fill_in 'Merchant ID', with: 'ABC'
          fill_in 'Merchant Key', with: 'DEF'
        end
        click_button 'Update'

        expect(page).to have_content 'Sisow settings updated'
        expect(page).to have_field('Merchant ID', with: 'ABC')
        expect(page).to have_field('Merchant Key', with: 'DEF')
      end

      scenario 'I want to change environment' do
        expect(page).to have_checked_field 'Test mode'
        expect(page).to have_unchecked_field 'Debug mode'

        within_fieldset 'Environment settings' do
          uncheck 'Test mode'
          check 'Debug mode'
        end
        click_button 'Update'

        expect(page).to have_content 'Sisow settings updated'
        expect(page).to have_unchecked_field 'Test mode'
        expect(page).to have_checked_field 'Debug mode'
      end
    end
  end
end
