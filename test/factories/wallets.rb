FactoryGirl.define do

  factory :invalid_model_wallet, class: Wallet do
    skip_create
    first_name 'Billy'
    last_name 'Budd'
  end

  factory :wallet do
    skip_create
    first_name 'Billy'
    last_name 'Budd'
    age 32
    account_number '123456789'
    email 'bill.budd@test.com'
    wallet_token 'wallet_1'

    factory :model_wallet_with_1_card, class: Wallet do
      wallet_token 'model_wallet_with_1_card'
      after(:build) do |wallet|
        wallet.cards << create(:card)
      end
    end

    factory :model_wallet_with_1_invalid_card, class: Wallet do
      wallet_token 'model_wallet_with_1_card'
      after(:build) do |wallet|
        wallet.cards << create(:model_invalid_card)
      end
    end

    factory :model_wallet_with_3_cards, class: Wallet do
      wallet_token 'model_wallet_with_3_cards'
      email 'bill.budd@test.com'
      after(:build) do |wallet|
        wallet.cards << create(:card)
        wallet.cards << create(:model_card_2)
        wallet.cards << create(:model_card_3)
      end

      factory :model_wallet_with_expired_card, class: Wallet do
        wallet_token 'wallet_with_expired_card'
        after(:build) do |wallet|
          wallet.cards << create(:expired_model_card)
        end

        factory :model_wallet_with_two_expired_cards, class: Wallet do
          after(:build) do |wallet|
            wallet.cards << create(:expired_model_card_2)
          end
        end

      end

    end
  end


end
