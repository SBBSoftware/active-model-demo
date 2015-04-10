FactoryGirl.define do

  factory :invalid_wallet_1, class: PlainWallet do
    skip_create
    first_name 'Billy'
    last_name 'Budd'
    age 32
    account_number '123456789'

    factory :wallet_without_cards, class: PlainWallet do
      wallet_token 'wallet_without_cards'
      email 'bill.budd@test.com'
    end

    factory :wallet_with_1_card, class: PlainWallet do
      wallet_token 'wallet_with_cards'
      email 'bill.budd@test.com'
      after(:build) do |wallet|
        wallet.cards << create(:plain_card_1)
      end
    end

    factory :wallet_with_3_cards, class: PlainWallet do
      wallet_token 'wallet_with_cards'
      email 'bill.budd@test.com'
      after(:build) do |wallet|
        wallet.cards << create(:plain_card_1)
        wallet.cards << create(:plain_card_2)
        wallet.cards << create(:plain_card_3)
      end

      factory :wallet_with_invalid_card, class: PlainWallet do
        wallet_token 'wallet_with_invalid_card'
        email 'bill.budd@test.com'
        after(:build) do |wallet|
          wallet.cards << create(:invalid_plain_card)
        end
      end

      factory :wallet_with_expired_card, class: PlainWallet do
        wallet_token 'wallet_with_expired_card'
        email 'bill.budd@test.com'
        after(:build) do |wallet|
          wallet.cards << create(:expired_plain_card_1)
        end

        factory :wallet_with_two_expired_cards, class: PlainWallet do
          after(:build) do |wallet|
            wallet.cards << create(:expired_plain_card_2)
          end
        end
      end
    end
  end
end
