# model class to encapsulate a credit card
class PlainCard
  attr_accessor :card_number, :last_4, :first_6, :card_token, :card_type, :expiration_date
  attr_reader :errors

  # set up object state on new
  def initialize(params = {})
    @card_number = nil
    @errors = []
    @expiration_date = nil
    self.attributes = params
  end

  # local update only, will not remotely save
  def update(params)
    self.attributes = params
  end

  # mimic AR attributes method
  def attributes
    {
        card_token: card_token,
        card_type: card_type,
        expiration_date: expiration_date,
        card_number: card_number
    }
  end

  # yay some logic. I want to accept a date,
  # a string which can be parsed into a date
  # or a MM/YY format string and change them into date objects
  def expiration_date=(date)
    if date.is_a?(Date)
      @expiration_date = date
    else
      # do we have a month/year in here? will accept 01/12 or 1/1 etc
      # must have 1 or 2 digit then forward slash then 1 or 2 digits
      if date =~ /\A\d{2}\/\d{1,2}\z/
        # some fun building a date out of that
        date_split = date.split('/')
        month, year = date_split[0].to_i, date_split[1].to_i
        if month.between?(1, 12)
          year > 30 ? year += 1900 : year += 2000
          # now make sure we have the last day of the month
          @expiration_date = Date.new(year, month, -1)
        end
        # create a date from month year
      else
        if date =~ /\A\d\/\d{1,2}\z/
          # tut tut tut
          @expiration_date = date
        else
          # try and parse the date
          begin
            @expiration_date = Date.parse(date)
          rescue ArgumentError
            # no date for you!
            @expiration_date = date
          end
        end
      end
    end
  end

  # check validity of entire object
  def valid?
    valid = expiration_date && expiration_date_valid? && card_type && check_card_type && card_number_valid?
    update_errors unless valid
    valid
  end

  # yay more logic provide the rest of the world
  # with a simple expiration test
  def expired?
    !expiration_date || expiration_date <= Date.today
  end

  # let two cards be the same if they have the same card token
  def ==(other)
    card_token == other.card_token
  end

  # private im not a fan of private
  # these methods may be considered private but ruby
  def check_card_type
    card_type && (card_type == 'VISA' || card_type == 'MASTERCARD' || card_type == 'AMEX')
  end

  # do we have a real date or are we holding garbage
  def expiration_date_valid?
    expiration_date.is_a? Date
  end

  # update error object based on current object state
  def update_errors
    @errors = []
    @errors << 'Expiration date is a required field' unless expiration_date
    @errors << 'Expiration Date is not a valid date' unless expiration_date.is_a? Date
    @errors << 'Card type is a required field' unless card_type
    @errors << 'Card type is not supported' unless check_card_type
    @errors << 'Card number is not valid' unless card_number_valid?
    @errors
  end

  # simple implementation, just counts characters
  def card_number_valid?
    if card_number
      card_number =~ /\A\d{13,16}\z/
    else
      true
    end
  end

  private

  # internal attribute setter
  def attributes=(params)
    params.each do |attr, value|
      public_send("#{attr}=", value)
    end
    self
  end

end
