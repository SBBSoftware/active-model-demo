require 'test_helper'
class PlainWalletTest < ActiveSupport::TestCase

  should 'be invalid without any parameters' do
    wallet = PlainWallet.new
    refute wallet.valid?
  end

  should 'be invalid without wallet token and email' do
    wallet = create(:invalid_wallet_1)
    refute wallet.valid?
  end

  should 'be valid with zero cards' do
    wallet = create(:wallet_without_cards)
    assert wallet.valid?
    assert wallet.warning?
  end

  should 'be invalid with invalid card' do
    wallet = create(:wallet_with_invalid_card)
    refute wallet.valid?
  end

  should 'be valid with all fields set correctly' do
    wallet = create(:wallet_with_3_cards)
    assert wallet.valid?
  end

  should 'set warning when 1 card is expired' do
    wallet = create(:wallet_with_expired_card)
    assert wallet.warning?
    assert wallet.messages[:expired_card]
  end

  should 'not set warning if no cards have expired' do
    wallet = create(:wallet_with_3_cards)
    refute wallet.warning?
    refute wallet.messages[:expired_card]
  end


  should 'set warning if wallet has no cards' do
    wallet = create(:wallet_without_cards)
    assert wallet.warning?
    assert wallet.messages[:empty_wallet]
  end

  should 'set 1 warning message when multiple cards are expired' do

    wallet = create(:wallet_with_two_expired_cards)
    assert wallet.warning?
    assert_equal 1, wallet.messages.length
  end

  should 'return mutable cards with accessor' do
    wallet = create(:wallet_with_3_cards)
    cards = wallet.cards
    cards.first.card_type = 'NOTYPE'
    assert wallet.cards.equal?(cards)
  end

  should 'update wallet attributes' do
    wallet = create(:wallet_with_3_cards)
    email = 'newemail@test.com'
    age = 190
    refute_equal email, wallet.email
    refute_equal age, wallet.age
    wallet.update(email: email, age: age)
    assert_equal email, wallet.email
    assert_equal age, wallet.age
  end

  should 'update card attributes' do
    wallet = create(:wallet_with_1_card)
    cards = wallet.cards
    cards.first.expiration_date = (Date.today - 5000)
    cards.first.first_6 = '000000'
    cards << create(:expired_plain_card_1)
    wallet.cards = cards
    assert_equal cards, wallet.cards
  end

  should 'save changes to wallet' do
    wallet = create(:wallet_with_1_card)
    assert wallet.save
  end

  should 'return false when saving invalid wallet' do
    wallet = create(:invalid_wallet_1)
    refute wallet.save
  end

  should 'raise exception when save! invalid wallet' do
    wallet = create(:invalid_wallet_1)
    assert_raises(RuntimeError) do
      wallet.save!
    end
  end

  should 'create new wallet with attributes' do
    params = attributes_for(:wallet_with_3_cards)
    wallet = PlainWallet.create(params)
    assert wallet.valid?
  end

  should 'save with idempotence' do
    wallet = create(:wallet_with_3_cards)
    wallet.save
    first_save_token = wallet.wallet_token
    wallet.save
    assert_equal first_save_token, wallet.wallet_token
  end

  should 'update wallet' do
    wallet = create(:wallet_with_3_cards)
    wallet.save
    first_name = 'changed'
    last_name = 'during'
    email = 'testing@testing.com'
    wallet.update(first_name: first_name, last_name: last_name, email: email)
    updated_wallet = PlainWallet.find(wallet.wallet_token)
    assert_equal first_name, updated_wallet.first_name
    assert_equal last_name, updated_wallet.last_name
    assert_equal email, updated_wallet.email
  end

  should 'not save an invalid wallet' do
    wallet = create(:wallet_with_3_cards)
    wallet.email = nil
    result = wallet.save
    refute result
  end

  should 'destroy card' do
    wallet = create(:wallet_with_3_cards)
    wallet.save
    card_count = wallet.cards.length
    wallet.destroy_plain_card(wallet.cards.length - 1)
    assert_equal card_count - 1, wallet.cards.length
  end

  should 'update card' do
    card_number = '0101010101010101'
    card_date = Date.today + 1
    wallet = create(:wallet_with_3_cards)
    wallet.save
    card = wallet.cards.first
    card.expiration_date = card_date
    card.card_number = card_number
    result = wallet.update_plain_card(0, card.attributes)
    assert result
    assert_equal card_number[0..6], wallet.cards.first.first_6
    assert_equal card_number[-4..-1], wallet.cards.first.last_4
    assert_equal card_date, wallet.cards.first.expiration_date
  end

  # # todo need to fix this use case
  # should 'not update card without card number' do
  #   wallet = create(:wallet_with_3_cards)
  #   wallet.save
  #   card = wallet.cards.first
  #   card.expiration_date = Date.today + 1
  #   card.card_type = 'AMEX'
  #   card.card_number = nil
  #   result = wallet.update_plain_card(1, card.attributes)
  #   refute result
  # end

  should 'find card by id' do
    wallet = create(:wallet_with_3_cards)
    wallet.save
    card_1 = wallet.cards.first
    card_2 = wallet.cards.last
    found_card_1 = wallet.find_plain_card(0)
    found_card_2 = wallet.find_plain_card(wallet.cards.length - 1)
    assert_equal card_1, found_card_1
    assert_equal card_2, found_card_2
  end

  should 'return nil when finding card which does not exist' do
    wallet = create(:wallet_with_3_cards)
    wallet.save
    card = wallet.find_plain_card(-9999)
    assert_nil(card)
  end

  context 'email validity check' do
    should 'allow valid email' do
      wallet = create(:wallet_with_3_cards)
      wallet.email = 'test@test.com'
      assert wallet.email_well_formed?
      wallet.email = 'bob.bobertson-boberton@test.com'
      assert wallet.email_well_formed?
    end

    should 'mark invalid email' do
      wallet = create(:wallet_with_3_cards)
      wallet.email = ''
      refute wallet.email_well_formed?
      wallet.email = 'test@test.com.'
      refute wallet.email_well_formed?
    end

  end

  should 'create new wallet' do
    wallet_params = attributes_for(:wallet_with_3_cards)
    wallet = Wallet.create(wallet_params)
    assert wallet.wallet_token
  end

end
