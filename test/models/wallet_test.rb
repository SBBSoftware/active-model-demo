require 'test_helper'
class WalletTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  setup do
    @model = Wallet.new
  end

  should validate_presence_of :wallet_token
  should validate_presence_of :email
  should allow_value('test@test.com').for(:email)
  should allow_value('bob.bobertson-boberton@test.com').for(:email)
  should_not allow_value('test@test').for(:email)
  should_not allow_value('test@test.com.').for(:email)

  should 'be invalid with invalid card' do
    wallet = create(:model_wallet_with_1_invalid_card)
    # wallet.cards.first.card_number = nil
    refute wallet.valid?
  end

  should 'set warning when 1 card is expired' do
    wallet = build(:model_wallet_with_expired_card)
    # due to FactoryGirl performing a save! on create we
    # need to build and save
    wallet.save
    assert wallet.warning?
    assert wallet.messages[:expired_card]
  end

  should 'not set warning if no cards have expired' do
    wallet = build(:model_wallet_with_3_cards)
    # due to FactoryGirl performing a save! on create we
    # need to build and save
    wallet.save
    refute wallet.warning?
    refute wallet.messages[:expired_card]
  end

  should 'set warning if wallet has no cards' do
    wallet = build(:wallet)
    # due to FactoryGirl performing a save! on create we
    # need to build and save
    wallet.save
    assert wallet.warning?
    assert wallet.messages[:empty_wallet]
  end

  should 'set 1 warning message when multiple cards are expired' do
    wallet = build(:model_wallet_with_two_expired_cards)
    # due to FactoryGirl performing a save! on create we
    # need to build and save
    wallet.save
    assert wallet.warning?
    assert_equal 1, wallet.messages.length
  end

  should 'return last 4 of account number with rest masked' do
    wallet = create(:wallet)
    crude_mask = ''
    (wallet.account_number.length - 4).times { crude_mask << 'x' }
    crude_mask << wallet.account_number[-4..-1]
    assert_equal crude_mask, wallet.account_number_unmask_last(4)
  end

  should 'mask with & instead of x' do
    wallet = create(:wallet)
    crude_mask = ''
    (wallet.account_number.length - 4).times { crude_mask << '&' }
    crude_mask << wallet.account_number[-4..-1]
    assert_equal crude_mask, wallet.account_number_unmask_last(4, '&')
  end

  # this has to test that the save has happened
  should 'save changes to wallet' do
    wallet = create(:model_wallet_with_1_card)
    assert wallet.save
  end

  should 'return false when saving invalid wallet' do
    wallet = create(:invalid_model_wallet)
    refute wallet.save
  end

  should 'raise exception when save! invalid wallet' do
    wallet = create(:invalid_model_wallet)
    assert_raises(RuntimeError) do
      wallet.save!
    end
  end

  should 'update wallet' do
    wallet = create(:model_wallet_with_3_cards)
    wallet.save
    first_name = 'changed'
    last_name = 'during'
    email = 'testing@testing.com'
    wallet.update(first_name: first_name, last_name: last_name, email: email)
    updated_wallet = Wallet.find(wallet.wallet_token)
    assert_equal first_name, updated_wallet.first_name
    assert_equal last_name, updated_wallet.last_name
    assert_equal email, updated_wallet.email

  end

  should 'save with idempotence' do
    wallet = create(:model_wallet_with_3_cards)
    wallet.save
    first_save_token = wallet.wallet_token
    wallet.save
    assert_equal first_save_token, wallet.wallet_token
  end

  should 'not save an invalid wallet' do
    wallet = create(:model_wallet_with_3_cards)
    wallet.email = nil
    result = wallet.save
    refute result
  end

  should 'destroy card' do
    wallet = create(:model_wallet_with_3_cards)
    wallet.save
    card_count = wallet.cards.length
    card = wallet.cards.first
    wallet.destroy_card(card.id)
    assert_equal card_count - 1, wallet.cards.length
  end

  should 'update card' do
    card_number = '0101010101010101'
    card_date = Date.today + 1
    wallet = create(:model_wallet_with_3_cards)
    wallet.save
    card = wallet.cards.first
    card.expiration_date = card_date
    card.card_number = card_number
    result = wallet.update_card(card.id, card.attributes)
    assert result
    remote_wallet = RemoteWallet.find_by_wallet_token(wallet.wallet_token)
    assert_equal card_number, remote_wallet.cards.first.card_number
    assert_equal card_date, wallet.cards.first.expiration_date
  end

  should 'not update card without card number' do
    wallet = create(:model_wallet_with_3_cards)
    wallet.save
    card = wallet.cards.first
    card.expiration_date = Date.today + 1
    card.card_type = 'AMEX'
    card.card_number = nil
    result = wallet.update_card(card.id, card.attributes)
    refute result
  end

  should 'not create card without card number' do
    wallet = create(:model_wallet_with_3_cards)
    wallet.save
    wallet.cards << Card.new(card_type: 'VISA', expiration_date: Date.today + 10)
    result = wallet.save
    refute result
  end

  should 'find card by id' do
    wallet = create(:model_wallet_with_3_cards)
    wallet.save
    card_1 = wallet.cards.first
    card_2 = wallet.cards.last
    found_card_1 = wallet.find_card(card_1.id)
    found_card_2 = wallet.find_card(card_2.id)
    assert_equal card_1, found_card_1
    assert_equal card_2, found_card_2
  end

  should 'return nil when finding card which does not exist' do
    wallet = create(:model_wallet_with_3_cards)
    wallet.save
    card = wallet.find_card('notanid')
    assert_nil(card)
  end

  should 'find index of card by id' do
    wallet = create(:model_wallet_with_3_cards)
    wallet.save
    card_1 = wallet.cards.first
    card_2 = wallet.cards.last
    assert_equal 0, wallet.index_of_card(card_1.id)
    assert_equal wallet.cards.length - 1, wallet.index_of_card(card_2.id)
  end

  should 'return nil for index when card does not exist' do
    wallet = create(:model_wallet_with_3_cards)
    wallet.save
    card = wallet.index_of_card('notanid')
    assert_nil(card)
  end

  should 'create new wallet' do
    wallet_params = attributes_for(:model_wallet_with_3_cards)
    wallet = Wallet.create(wallet_params)
    assert wallet.wallet_token
  end

end
