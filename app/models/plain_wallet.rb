# model object to hold wallet data and many cards
class PlainWallet
  # mixin the remote service delegate
  include RemoteSbbWalletDelegate

  # note that state and data are mixed together in the declaration
  attr_accessor :valid, :wallet_token,
                :first_name, :last_name, :email, :age, :account_number

  # we need special handling of these fields
  attr_reader :cards, :errors

  # find wallet by wallet token
  def self.find(wallet_token)
    # we need to make a remote call to get the wallet from our service provider
    # I am skipping the error handling
    response = remote_find(wallet_token)
    new(response)
  end

  # create a new model and persist it
  def self.create(**attributes)
    wallet = new(attributes)
    wallet.save
    wallet
  end

  # even with a ruby object, its worth investing in
  # attribute based initialization for a model object
  def initialize(params = {})
    # set up our initial wallet state
    @messages ||= {}
    # @warning = false
    @cards ||= []
    @errors ||= []
    self.attributes = params
  end

  # we will check for both expired cards and wallets with no cards
  def check_warnings
    @messages = {}
    @messages[:expired_card] = MESSAGES[:expired_card] if cards.any?(&:expired?) # { |card| card.expired? }
    @messages[:empty_wallet] = MESSAGES[:empty_wallet] if @cards.length < 1
    @messages.length > 0
  end

  # mimic AR attributes method
  def attributes
    {
        cards_attributes: cards.map(&:attributes), # { |card| card.attributes },
        wallet_token: wallet_token,
        first_name: first_name,
        last_name: last_name,
        email: email,
        age: age,
        account_number: account_number
    }
  end

  # if we replace our card array we need to update our warnings
  def cards=(cards)
    @cards = cards
    check_warnings
  end

  # need this to mimic accepts_nested_attributes_for
  def cards_attributes=(cards)
    @cards = []
    cards.each do |card|
      @cards << PlainCard.new(card)
    end
  end

  # do we have a warning message
  def warning?
    check_warnings
  end

  # return warning messages
  def messages
    check_warnings
    @messages
  end

  # validity check for wallet and all cards
  def valid?
    valid = cards.all?(&:valid?) && wallet_token && email_well_formed?
    update_errors unless valid
    valid
  end

  # yes, this truly belongs in that convenience library with 2 dozen other methods
  # I keep promising ill write
  def email_well_formed?
    # thank you devise
    email && email =~ /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/
  end

  # we need to enumerate errors in the object and create an error array
  def update_errors
    @errors = []
    @errors << 'One of the cards needs attention' unless cards.all?(&:valid?)
    if email
      @errors << 'Email is not in correct format' unless email_well_formed?
    else
      @errors << 'Email is a required field'
    end
    @errors << 'Wallet token is a required field' unless wallet_token
    @errors
  end

  # allow for wallet to be updated and saved
  def update(params)
    self.attributes = params
    save
  end

  # persist change remotely similar to activerecord.save
  def save
    if valid?
      remote_attributes = remote_save(attributes)
      # need to update our attributes with the response from the remote service
      self.attributes = remote_attributes if remote_attributes
      true
    else
      false
    end
  end

  # persist change remotely similar to activerecord.save!
  def save!
    if save
      true
    else
      fail 'InvalidWallet'
    end
  end

  # find cards by their position in the array
  def find_plain_card(id)
    cards[id]
  end

  # change and persist one card
  def update_plain_card(id, params)
    card = find_plain_card(id)
    card.update(params)
    if card.valid?
      save
    end
  end

  # delete plain card
  def destroy_plain_card(id)
    cards.delete_at(id)
    save
  end

  private

  def attributes=(params)
    # forgive me father for i have sinned
    # spare me from ruby injection because
    # im not coding any protection
    params.each_pair do |k, v|
      setter = "#{k}=".to_sym
      public_send(setter, v)
    end
    # we need to check sub objects on initialization
    check_warnings
  end

end
