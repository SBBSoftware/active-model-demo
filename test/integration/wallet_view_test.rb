require 'test_helper'
class WalletViewTest < ActionDispatch::IntegrationTest

  setup do
    # need this to make sure we have a session id
    page.get_rack_session
  end
  demo_link = 'ActiveModel Demo'

  should 'show default card number label on show wallet card table' do
    visit(root_path)
    click_link demo_link
    # visit(wallet_path)
    assert page.has_content?('Card number')
  end

  should 'show uk version of card number label on show wallet card table' do
    I18n.locale = :uk
    visit(root_path)
    click_link demo_link
    assert page.has_content?('Primary account number')
    I18n.locale = :en
  end

  should 'update wallet when fields are complete' do
    visit(root_path)
    click_link demo_link
    click_link('edit wallet')
    email_edit = 'integration_test@test.com'
    fill_in('Email', with: email_edit)
    click_button('Update')
    assert page.has_content?('Your wallet was successfully updated.')
    assert page.has_content?("Email #{email_edit}")
  end

end
