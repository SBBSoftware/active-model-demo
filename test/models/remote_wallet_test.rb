require 'test_helper'
class RemoteWalletTest < ActiveSupport::TestCase

  should validate_presence_of :email
  should allow_value('test@test.com').for(:email)
  should allow_value('bob.bobertson-boberton@test.com').for(:email)
  should_not allow_value('test@test').for(:email)
  should_not allow_value('test@test.com.').for(:email)

  context 'unique validations' do
    subject { build(:remote_wallet_with_one_card) }
    should validate_uniqueness_of :wallet_token
  end

  context 'token generation turned off' do
    should 'validate presence of card_token' do
      RemoteWallet.skip_callback(:validation, :before, :generate_token)
      wallet = create(:remote_wallet_with_one_card)
      wallet.wallet_token = nil
      assert_raise ActiveRecord::RecordInvalid do
        wallet.save!
      end
      RemoteWallet.set_callback(:validation, :before, :generate_token)
    end
  end

  should 'always generate a token when none is supplied' do
    wallet = RemoteWallet.create(email: 'test@test.com')
    refute_nil wallet.wallet_token
  end

  should 'not generate a token when one is supplied' do
    token = 'supplied_token'
    wallet = RemoteWallet.create(wallet_token: token, email: 'test@test.com')
    refute_nil wallet.wallet_token
    assert_equal token, wallet.wallet_token
  end


  should 'create new wallet when none exists' do
    wallet_params = params_for_factory_wallet_and_cards(:remote_wallet_with_cards)
    existing_wallet = RemoteWallet.find_by_wallet_token(wallet_params[:wallet_token])
    assert_nil existing_wallet
    wallet = RemoteWallet.create_or_update(wallet_params[:wallet_token], wallet_params)
    assert_equal wallet_params[:cards_attributes].length, wallet.cards.length
    assert_equal wallet_params[:cards_attributes].last[:expiration_date], wallet.cards.last.expiration_date
    assert_equal wallet_params[:email], wallet.email
  end

  should 'update wallet when one exists' do
    original_wallet = create(:remote_wallet_with_cards)
    wallet_params = params_for_wallet_and_cards(original_wallet)
    wallet_params[:email] = 'changed@email.com'
    wallet_params[:first_name] = 'changed name'
    wallet = RemoteWallet.create_or_update(wallet_params[:wallet_token], wallet_params)
    assert_equal original_wallet.id, wallet.id
    assert_equal wallet_params[:email], wallet.email
    assert_equal wallet_params[:first_name], wallet.first_name
  end

  should 'delete cards from wallet not sent in update' do
    original_wallet = create(:remote_wallet_with_cards)
    (0..(original_wallet.cards.count - 2)).each_with_index do |index|
      original_wallet.cards[index].destroy
    end
    original_wallet.reload
    wallet_params = params_for_wallet_and_cards(original_wallet)
    wallet = RemoteWallet.create_or_update(wallet_params[:wallet_token], wallet_params)
    assert_equal 1, wallet.cards.count
    assert_equal original_wallet.cards.first.card_token, wallet.cards.first.card_token
  end

  should 'update one existing card in the wallet' do
    original_wallet = create(:remote_wallet_with_cards)
    # wallet_params = params_f
    # or_wallet_and_cards(:remote_wallet_with_cards)
    wallet_params = params_for_wallet_and_cards(original_wallet)
    new_card_number = '9999999999999'
    wallet_params[:cards_attributes].first[:card_number] = new_card_number
    wallet = RemoteWallet.create_or_update(wallet_params[:wallet_token], wallet_params)
    assert_equal original_wallet.id, wallet.id
    assert_equal original_wallet.cards.count, wallet.cards.count
    assert_equal original_wallet.cards.as_added.first.id, wallet.cards.as_added.first.id
    assert_equal original_wallet.cards.as_added.first.card_token, wallet.cards.as_added.first.card_token
    assert_equal new_card_number, wallet.cards.as_added.first.card_number
    assert_equal original_wallet.cards.as_added.last, wallet.cards.as_added.last
  end

  should 'add new cards to existing wallet' do
    original_wallet = create(:remote_wallet_with_one_card)
    wallet_params = params_for_wallet_and_cards(original_wallet)
    added_card = attributes_for(:remote_card_2)
    wallet_params[:cards_attributes] << added_card
    wallet = RemoteWallet.create_or_update(original_wallet.wallet_token, wallet_params)
    assert_equal original_wallet.id, wallet.id
    assert_equal original_wallet.cards.first.id, wallet.cards.first.id
    assert_equal original_wallet.cards.first.card_number, wallet.cards.first.card_number
    assert_equal 2, wallet.cards.count
    refute_equal original_wallet.cards.last.id, wallet.cards.last.id
    assert_equal added_card[:card_token], wallet.cards.last.card_token
    assert_equal added_card[:card_number], wallet.cards.last.card_number
  end

  should 'add delete and update cards' do
    original_wallet = create(:remote_wallet_with_cards)
    wallet_params = params_for_wallet_and_cards(original_wallet)
    deleted_card = wallet_params[:cards_attributes].delete_at(0)
    wallet_params[:cards_attributes].first[:card_number] = '0000000000000000'
    added_card = attributes_for(:remote_card_4)
    wallet_params[:cards_attributes] << added_card
    wallet = RemoteWallet.create_or_update(original_wallet.wallet_token, wallet_params)
    assert_equal 3, wallet.cards.count
    refute_equal deleted_card[:card_number], wallet.cards.as_added.first.card_number
    assert_equal '0000000000000000', wallet.cards.as_added.first.card_number
    assert_equal added_card[:card_number], wallet.cards.as_added.last.card_number
  end

  should 'create mock wallet when none exists' do
    token = 'testsession'
    wallet_attributes = RemoteWallet.default_wallet(token)
    assert_equal token, wallet_attributes['wallet_token']
    assert_equal MOCK_WALLET[:email], wallet_attributes['email']
  end

  should 'create mock wallet for new wallet token' do
    RemoteWallet.default_wallet('existing_token')
    token = 'testsession'
    wallet_attributes = RemoteWallet.default_wallet(token)
    assert_equal token, wallet_attributes['wallet_token']
    assert_equal MOCK_WALLET[:email], wallet_attributes['email']
    assert_equal 2, RemoteWallet.count
  end

  def params_for_wallet_and_cards(wallet)
    card_params = []
    wallet.cards.each do |card|
      card_params << card.attributes
      card_params.delete('id')
      card_params.delete('remote_wallet_id')
    end
    params = wallet.attributes
    params.delete('id')
    params['cards_attributes'] = card_params
    params.recursive_symbolize_keys!
    params
  end

  def params_for_factory_wallet_and_cards(factory_name)
    wallet_params = attributes_for(factory_name)
    card_params = [attributes_for(:remote_card_1),
                   attributes_for(:remote_card_2),
                   attributes_for(:remote_card_3)]
    wallet_params[:cards_attributes] = card_params
    wallet_params.recursive_symbolize_keys!
    wallet_params
  end
end
