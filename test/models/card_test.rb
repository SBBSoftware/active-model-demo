require 'test_helper'
class CardTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests
  setup do
    @model = Card.new
  end

  should validate_presence_of :expiration_date
  should validate_presence_of :card_type
  should validate_presence_of(:card_number), unless: proc { |card| card.changed? }
  should validate_length_of(:card_number).is_at_least(13).is_at_most(16), unless: proc { |card| card.changed? }
  should validate_inclusion_of(:card_type).in_array(%w(VISA MASTERCARD AMEX))

  context 'card number' do
    should 'not check blank validation unless changed' do
      card = create(:card)
      card.card_number = nil
      card.remotely_saved
      assert card.valid?
    end

    should 'not check length validation unless changed' do
      card = create(:card)
      card.card_number = '123456789012'
      card.remotely_saved
      assert card.valid?
      card.card_number = '12345678901234567'
      card.remotely_saved
      assert card.valid?
    end

    should 'not allow blank card number if changed' do
      card = create(:card)
      card.card_number = nil
      refute card.valid?
    end

    should 'not allow less than 13 or more than 16 characters if changed' do
      card = create(:card)
      card.card_number = '123456789012'
      refute card.valid?
      card.card_number = '12345678901234567'
      refute card.valid?
      card.card_number = '1234567890123'
      assert card.valid?
      card.card_number = '1234567890123456'
      assert card.valid?
    end

    # should 'assign last_4 on valid change' do
    #   card = create(:card)
    #   card.card_number = '4444555566667777'
    #   assert_equal '7777', card.last_4
    # end
    #
    # should 'assign first_6 on valid change' do
    #   card = create(:card)
    #   card.card_number = '4444555566667777'
    #   assert_equal '444455', card.first_6
    # end
    #
    # should 'set last_4 to nil unless valid change' do
    #   card = create(:card)
    #   card.card_number = '444455556666'
    #   assert_nil card.last_4
    # end
    #
    # should 'set first_6 to nil unless valid change' do
    #   card = create(:card)
    #   card.card_number = '444455556666'
    #   assert_nil card.first_6
    # end
  end

  context 'expiration date' do
    card = nil
    setup do
      card = build(:card)
    end

    should 'be valid with a date' do
      card.expiration_date = Date.new(2015, 1, 1)
      assert card.valid?
    end

    should 'be valid when using a parseable date' do
      card.expiration_date = '2215-01-01'
      assert card.valid?
    end

    should 'be valid when using mm/yy format' do
      card.expiration_date = '01/15'
      assert card.valid?
    end

    should 'not be valid when mm/yy is not a month' do
      card.expiration_date = '13/15'
      refute card.valid?
      card.expiration_date = '00/15'
      refute card.valid?
      card.expiration_date = '99/15'
      refute card.valid?
    end

    should 'not be valid for non existent date' do
      card.expiration_date = '2015-2-31'
      refute card.valid?
    end

    should 'not be valid for other strings' do
      card.expiration_date = 'sometime in 2015'
      refute card.valid?
    end

    should 'not be valid for m/yy' do
      card.expiration_date = '1/15'
      refute card.valid?
    end
  end

  should 'recognize expired card' do
    card = build(:expired_model_card)
    assert card.expired?
  end

  should 'recognize non expired card' do
    card = build(:card)
    refute card.expired?
  end

  context 'short expiration date' do
    card = nil
    setup do
      card = build(:card)
    end

    should 'convert mm/yy to last day of the month' do
      date = Date.new(2015, 12, 31)
      card.short_expiration = '12/15'
      assert card.valid?
      assert_equal date, card.expiration_date
    end

    should 'convert mm/yy with year greater than 30 to 20th century' do
      date = Date.new(1931, 12, 31)
      card.short_expiration = '12/31'
      assert card.valid?
      assert_equal date, card.expiration_date
    end

    should 'convert mm/yy with year smaller than 31 to 21st century' do
      date = Date.new(2030, 12, 31)
      card.short_expiration = '12/30'
      assert card.valid?
      assert_equal date, card.expiration_date
    end
  end

end
