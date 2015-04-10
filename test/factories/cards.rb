FactoryGirl.define do

  factory :card do
    skip_create
    card_token 'card_1'
    card_type 'VISA'
    card_number '1234567890123'
    expiration_date (Date.today + 400)

    factory :model_card_2 do
      card_token 'model_card_2'
      card_type 'MASTERCARD'
    end

    factory :model_card_3 do
      card_token 'model_card_3'
      card_type 'AMEX'
      card_number '1234567890123'
    end

    factory :expired_model_card do
      card_token 'expired_card_1'
      card_type 'VISA'
      expiration_date (Date.today - 1)
    end

    factory :expired_model_card_2 do
      card_token 'expired_card_2'
      card_type 'MASTERCARD'
      expiration_date (Date.today - 1)
    end

  end

  factory :model_invalid_card, class: Card do
    skip_create
    card_token 'model_invalid'
  end


end
