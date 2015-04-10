require 'test_helper'
class AddNewPlainCardTest < ActionDispatch::IntegrationTest

  setup do
    # need this to make sure we have a session id
    page.get_rack_session
  end

  demo_link = 'Ruby Object Demo'

  should 'add card when all fields complete' do
    visit(root_path)
    click_link demo_link
    click_link 'add card'
    fill_in('Card number', with: '1234123412341234')
    fill_in('Expiration date', with: '02/16')
    select 'VISA'
    click_button('Add Card')
    assert page.has_content?('Card was successfully created.')
  end

  should 'show error page when no fields are complete' do
    visit(root_path)
    click_link demo_link
    click_link 'add card'
    click_button('Add Card')
    assert page.has_content?('errors prohibited this card from being saved')
  end

  should 'return to wallet view from add card form cancel' do
    visit(root_path)
    click_link demo_link
    click_link 'add card'
    click_link('Cancel')
    assert page.has_content?(/Your[a-zA-Z\s]+Wallet/)
  end

end
