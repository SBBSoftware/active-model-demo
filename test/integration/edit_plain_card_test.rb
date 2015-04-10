require 'test_helper'
class EditPlainCardTest < ActionDispatch::IntegrationTest

  setup do
    # need this to make sure we have a session id
    page.get_rack_session
  end

  demo_link = 'Ruby Object Demo'

  should 'edit card when all fields complete' do
    card_number = '9999888877776666'
    visit(root_path)
    click_link demo_link
    first(:link, 'Edit').click
    fill_in('Card number', with: card_number)
    fill_in('Expiration date', with: '02/17')
    select 'VISA'
    click_button('Update Card')
    assert page.has_content?('Card was successfully updated.')
    assert page.has_content?(card_number[-4..-1])
  end

  should 'show error page when no fields are complete' do
    visit(root_path)
    click_link demo_link
    first(:link, 'Edit').click
    click_button('Update Card')
    assert page.has_content?('prohibited this card from being saved')
  end

  should 'return to wallet view from add card form cancel' do
    visit(root_path)
    click_link demo_link
    first(:link, 'Edit').click
    click_link('Cancel')
    assert page.has_content?(/Your[a-zA-Z\s]+Wallet/)
  end
end
