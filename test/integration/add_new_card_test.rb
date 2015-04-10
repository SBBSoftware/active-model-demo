require 'test_helper'
class AddNewCardTest < ActionDispatch::IntegrationTest

  setup do
    # need this to make sure we have a session id
    page.get_rack_session
  end

  demo_link = 'ActiveModel Demo'

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

  should 'show default card number label on add card form' do
    visit(root_path)
    click_link demo_link
    click_link 'add card'
    # visit(wallet_path)
    assert page.has_content?('Card number')
  end

  should 'show uk version of card number label on add card form' do
    I18n.locale = :uk
    visit(root_path)
    click_link 'ActiveModel Demo'
    click_link 'add card'
    # visit(wallet_path)
    assert page.has_content?('Primary account number')
    I18n.locale = :en
  end


end
