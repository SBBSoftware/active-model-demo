# active model implementation of Card facade
class Card
  include ActiveModel::AttributeMethods,
          ActiveModel::Validations::Callbacks,
          ActiveModel::Serializers::JSON,
          ActiveModel::Dirty,
          ActiveModel::Model

  # after_validation :create_date # refactored away left for article
  attr_reader :card_type, :expiration_date, :card_number
  attr_accessor :last_4, :first_6, :card_token

  validates :card_type, :expiration_date, presence: true
  validates :card_number, presence: true, if: :changed?
  validates :card_number, length: { in: 13..16 }, if: :changed?
  validates :card_type, inclusion: { in: %w( VISA MASTERCARD AMEX ) }
  validates :expiration_date, multi_date_type: true

  define_attribute_methods :card_number, :card_type, :expiration_date

  # attributes for json, xml and hash export
  def attributes
    {
        card_token: card_token,
        card_type: card_type,
        expiration_date: expiration_date,
        card_number: card_number
    }
  end

  # setter for card_number
  def card_number=(value)
    card_number_will_change!
    @card_number = value
  end

  # setter for card type
  def card_type=(value)
    card_type_will_change!
    @card_type = value
  end

  # setter for expiration date
  def expiration_date=(value)
    expiration_date_will_change!
    @expiration_date = value
  end

  # virtual attribute short expiration getter
  def short_expiration
    if expiration_date.is_a? Date
      "#{expiration_date.strftime('%m')}/#{expiration_date.strftime('%y')}"
    else
      @short_expiration
    end
  end

  # virtual attribute short expiration setter
  def short_expiration=(expiration)
    return unless expiration
    @short_expiration = expiration
    /\A(?<month>\d{2})\/(?<year>\d{1,2})\z/ =~ expiration
    if month && year
      month, year = month.to_i, year.to_i
      # take a guess at what century we're in
      year > 30 ? year += 1900 : year += 2000
      # now make sure we have the last day of the month
      self.expiration_date = Date.new(year, month, -1)
    else
      self.expiration_date = expiration
    end
  end

  # generate an id from data. do not use not safe!!
  def id
    "#{last_4}#{card_type.each_byte.map.inject { |a, e| a + e }}".to_i if persisted?
  end

  # mark state as being saved, removes changed markers
  def remotely_saved
    changes_applied
  end

  # turn existence of card_token into boolean
  def persisted?
    card_token ? true : false
  end

  # simple expiration test
  def expired?
    !expiration_date || expiration_date <= Date.today
  end

  # set attribute by hash
  def update(params)
    self.attributes = params
  end

  private

  # internal attribute setter
  def attributes=(params)
    params.each do |attr, value|
      public_send("#{attr}=", value)
    end
    self
  end

  # refactored away as part of the Serialization section
  # # handle callback after validation to convert
  # # expiration_date content into a real date
  # def create_date
  #   # this will stop all other callbacks from processing
  #   # return false unless self.errors.empty?
  #   return true if expiration_date.is_a? Date
  #   # must be just mm/yy left
  #   /\A(?<month>\d{2})\/(?<year>\d{1,2})\z/ =~ expiration_date
  #   if month && year
  #     month, year = month.to_i, year.to_i
  #     # take a guess at what century we're in
  #     year > 30 ? year += 1900 : year += 2000
  #     # now make sure we have the last day of the month
  #     self.expiration_date = Date.new(year, month, -1)
  #   else
  #     false
  #   end
  # end
end
