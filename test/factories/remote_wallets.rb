FactoryGirl.define do

  factory :remote_wallet_with_cards, class: RemoteWallet do
    wallet_token 'wallet_with_cards'
    email 'bill.budd@test.com'
    first_name 'Billy'
    last_name 'Budd'
    age 32
    account_number '123456789'
    after(:build) do |wallet|
      wallet.cards << create(:remote_card_1)
      wallet.cards << create(:remote_card_2)
      wallet.cards << create(:remote_card_3)
    end
  end

  factory :remote_wallet_with_one_card, class: RemoteWallet do
    wallet_token 'wallet_with_cards'
    email 'bill.budd@test.com'
    first_name 'Billy'
    last_name 'Budd'
    age 32
    account_number '123456789'
    after(:build) do |wallet|
      wallet.cards << create(:remote_card_1)
    end
  end

end