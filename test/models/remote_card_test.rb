require 'test_helper'
class RemoteCardTest < ActiveSupport::TestCase

  should validate_presence_of :card_number
  should validate_presence_of :expiration_date
  should validate_presence_of :card_type

  should validate_length_of(:card_number).is_at_least(13).is_at_most(16)

  should validate_inclusion_of(:card_type).in_array(%w(VISA MASTERCARD AMEX))


  context 'unique validations' do
    subject { build(:remote_card_1) }
    should validate_uniqueness_of :card_token
  end

  context 'token generation turned off' do

    should 'validate presence of card_token' do
      RemoteCard.skip_callback(:validation, :before, :generate_token)
      card = create(:remote_card_1)
      card.card_token = nil
      assert_raise ActiveRecord::RecordInvalid do
        card.save!
      end
      card.card_token = ''
      assert_raise ActiveRecord::RecordInvalid do
        card.save!
      end
      RemoteCard.set_callback(:validation, :before, :generate_token)
    end

  end


  should 'always generate a token card_token is nil' do
    params = attributes_for(:remote_card_1)
    params.delete(:card_token)
    card = RemoteCard.new(params)
    assert_nil card.card_token
    card.save
    refute_nil card.card_token
  end

  should 'always generate a token card_token is blank' do
    params = attributes_for(:remote_card_1)
    params[:card_token] = ''
    card = RemoteCard.new(params)
    assert_equal '', card.card_token
    card.save
    refute_nil card.card_token
  end

  should 'not generate a token when one is supplied' do
    params = attributes_for(:remote_card_1)
    token = params[:card_token]
    card = RemoteCard.new(params)
    card.save
    refute_nil card.card_token
    assert_equal token, card.card_token
  end

  should 'return last 4 when card number greater than 4 characters' do
    card = create(:remote_card_1)
    assert_equal card.last_4, card.card_number[-4..-1]
  end

  should 'return first 6 when card number greater than 4 characters' do
    card = create(:remote_card_1)
    assert_equal card.first_6, card.card_number[0..6]
  end

  should 'return blank instead of last 4 or fist 6 when card number is blank' do
    card = RemoteCard.new
    card.card_number = ''
    assert_nil card.last_4
    assert_nil card.first_6
  end

  should 'return nil instead of last 4 or fist 6 when card number is nil' do
    card = RemoteCard.new
    assert_nil card.last_4
    assert_nil card.first_6
  end


end
