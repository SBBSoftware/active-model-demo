FactoryGirl.define do

  factory :invalid_plain_card, class: PlainCard do
    skip_create
    card_number '1234567890123456'
    last_4 3456
    first_6 123456

    factory :plain_card_1 do
      card_token 'card_1'
      card_type 'VISA'
      expiration_date (Date.today + 100)

      factory :plain_card_2 do
        card_token 'card_2'
        card_type 'MASTERCARD'
      end

      factory :plain_card_3 do
        card_token 'card_3'
        card_type 'AMEX'
      end

      factory :plain_card_1_duplicate do
      end

      factory :expired_plain_card_1 do
        card_token 'expired_card_1'
        card_type 'VISA'
        expiration_date (Date.today - 1)
      end

      factory :expired_plain_card_2 do
        card_token 'expired_card_2'
        card_type 'MASTERCARD'
        expiration_date (Date.today - 1)
      end
    end
  end
end
