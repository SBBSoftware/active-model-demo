require 'test_helper'
class PlainCardTest < ActiveSupport::TestCase

  should 'mark card without token, type or expiration as invalid' do
    card = create(:invalid_plain_card)
    refute card.valid?
    card.card_token = 'token'
    refute card.valid?
    card.card_type = 'VISA'
    refute card.valid?
    card.expiration_date = Date.new(2020, 8, 24)
    assert card.valid?
  end

  should 'return valid for card with all fields' do
    card = create(:plain_card_1)
    assert card.valid?
  end

  should 'respond to attributes' do
    card = create(:plain_card_1)
    card_attributes = card.attributes
    assert_equal card.card_number, card_attributes[:card_number]
    assert_equal card.card_token, card_attributes[:card_token]
  end

  should 'recognize expired card' do
    card = create(:expired_plain_card_1)
    assert card.expired?
  end

  should 'recognize non expired card' do
    card = create(:plain_card_1)
    refute card.expired?
  end

  should 'mark cards with no expiration as expired' do
    card = create(:invalid_plain_card)
    assert card.expired?
  end

  should 'return valid when card type is VISA, MASTERCARD or AMEX' do
    card = create(:plain_card_1)
    card.card_type = 'VISA'
    assert card.valid?
    card.card_type = 'MASTERCARD'
    assert card.valid?
    card.card_type = 'AMEX'
    assert card.valid?
  end

  should 'return invalid when card type is visa mastercard or amex' do
    card = create(:plain_card_1)
    card.card_type = 'visa'
    refute card.valid?
    card.card_type = 'mastercard'
    refute card.valid?
    card.card_type = 'amex'
    refute card.valid?
  end

  should 'return equal for two cards with the same value' do
    card_1 = create(:plain_card_1)
    card_1_duplicate = create(:plain_card_1_duplicate)
    assert_equal card_1, card_1_duplicate
  end

  context 'creating new credit card numbers' do
    should 'be valid with no credit card number' do
      card = create(:plain_card_1)
      card.card_number = nil
      assert card.valid?
      assert_nil card.card_number
    end

    should 'allow between 13 to 16 characters only' do
      card = create(:plain_card_1)
      assert card.valid?

      card.card_number = '123456789012'
      refute card.card_number_valid?
      refute card.valid?

      card.card_number = '12345678901234567'
      refute card.card_number_valid?
      refute card.valid?

      card.card_number = '1234567890123456'
      assert card.card_number_valid?
      assert card.valid?

      card.card_number = '1234567890123'
      assert card.card_number_valid?
      assert card.valid?
    end

    # should 'use last 4 from new card if valid' do
    #   card = create(:plain_card_1)
    #   card.card_number = '4444555566667777'
    #   assert_equal '7777', card.last_4
    # end
    #
    # should 'use first 6 from new card if valid' do
    #   card = create(:plain_card_1)
    #   card.card_number = '4444555566667777'
    #   assert_equal '444455', card.first_6
    # end
    #
    # should 'set last 4 to nil if card number not valid' do
    #   card = create(:plain_card_1)
    #   card.card_number = '000000000000000000000000'
    #   assert_nil card.last_4
    # end
    #
    # should 'set first 6 to nil if card number not valid' do
    #   card = create(:plain_card_1)
    #   card.card_number = '000000000000000000000000'
    #   assert_nil card.first_6
    # end
  end

  context 'expiration date' do

    should 'accept date' do
      card = create(:plain_card_1)
      date = Date.new(2215, 01, 01)
      card.update(expiration_date: date)
      assert card.valid?
      assert_equal date, card.expiration_date
    end

    should 'accept formatted date string' do
      card = create(:plain_card_1)
      date = Date.parse('2215-03-12')
      card.update(expiration_date: '2215-03-12')
      assert card.valid?
      assert_equal date, card.expiration_date
    end

    should 'mark invalid for non dates' do
      card = create(:plain_card_1)
      card.update(expiration_date: '2/')
      assert_equal '2/', card.expiration_date
      refute card.valid?
    end

    should 'set error for invalid date format' do
      card = create(:plain_card_1)
      card.update(expiration_date: '2/')
      assert_equal '2/', card.expiration_date
      refute card.valid?
      assert card.errors.include?('Expiration Date is not a valid date')
    end

    should 'not accept month year format without leading zero' do
      card = create(:plain_card_1)
      card.update(expiration_date: '2/15')
      assert_equal '2/15', card.expiration_date
      refute card.valid?
      assert card.errors.include?('Expiration Date is not a valid date')
    end

    should 'accept month year format with leading zero' do
      card = create(:plain_card_1)
      card.update(expiration_date: '02/15')
      assert card.valid?
      assert_equal Date.parse('2015-02-28'), card.expiration_date
    end

    should 'use final day of month for month year format' do
      card = create(:plain_card_1)
      card.update(expiration_date: '11/15')
      assert card.valid?
      assert_equal Date.parse('2015-11-30'), card.expiration_date
    end

    should 'convert years greater than 30 to 20th century' do
      card = create(:plain_card_1)
      card.update(expiration_date: '02/31')
      assert card.valid?
      assert_equal Date.parse('1931-02-28'), card.expiration_date
    end
  end
end
