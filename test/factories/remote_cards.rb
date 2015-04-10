FactoryGirl.define do

  factory :remote_card_1, class: RemoteCard do
    card_token 'card_1'
    card_type 'VISA'
    expiration_date (Date.today + 100)
    card_number '1234567890123456'

    factory :remote_card_2 do
      card_token 'card_2'
      card_type 'MASTERCARD'
    end

    factory :remote_card_3 do
      card_token 'card_3'
      card_type 'AMEX'
      expiration_date (Date.today - 5)
    end

    factory :remote_card_4 do
      card_token 'card_4'
      card_type 'MASTERCARD'
      card_number '111111111111111'
      expiration_date (Date.today - 5)
    end
  end

end