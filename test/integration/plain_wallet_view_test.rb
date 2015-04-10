require 'test_helper'
class PlainWalletViewTest < ActionDispatch::IntegrationTest

  setup do
    # need this to make sure we have a session id
    page.get_rack_session
  end
  demo_link = 'Ruby Object Demo'
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
