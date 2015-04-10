require 'test_helper'
class RemoteSbbWalletDelegateTest < ActiveSupport::TestCase

  setup do
    @remote_delegate = Class.new do
      include RemoteSbbWalletDelegate
    end.new
  end

  # not really necessary but...
  should 'be included in instance' do
    assert @remote_delegate.is_a? RemoteSbbWalletDelegate
    assert @remote_delegate.class.method_defined?(:remote_save)
    metaclass = @remote_delegate.singleton_class
    assert metaclass.methods.include?(:convert_remote_card)
    assert metaclass.methods.include?(:convert_remote_wallet)
    assert metaclass.methods.include?(:remote_find)
  end

  should 'convert wallet to local compatible attributes' do
    wallet = create(:remote_wallet_with_cards)
    params = @remote_delegate.class.convert_remote_wallet(wallet)
    assert_equal wallet.cards.first.card_token, params['cards_attributes'].first['card_token']
    assert_equal wallet.cards.last.card_token, params['cards_attributes'].last['card_token']
  end

  should 'add last_4 and first_6 to remote card attributes' do
    card = create(:remote_card_1)
    params = @remote_delegate.class.convert_remote_card(card)
    assert_equal params['last_4'], card.card_number[-4..-1]
    assert_equal params['first_6'], card.card_number[0..6]
  end

  should 'suppress id, wallet id account number from remote attributes' do
    card = create(:remote_card_1)
    params = @remote_delegate.class.convert_remote_card(card)
    assert_nil params['id']
    assert_nil params['remote_wallet_id']
    assert_nil params['card_number']
  end
end
