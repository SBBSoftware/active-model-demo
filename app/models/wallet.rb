# activemodel implementation of Wallet facade
class Wallet
  include RemoteSbbWalletDelegate,
          ActiveModel::AttributeMethods,
          ActiveModel::Validations::Callbacks,
          ActiveModel::Serialization,
          ActiveModel::Model
  extend ActiveModel::Callbacks

  attr_accessor :wallet_token, :first_name, :last_name, :email, :age, :account_number, :cards

  attr_reader :messages

  validates :wallet_token, :email, presence: true
  validates :email, format: { with: /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/ }
  validate :cards_validation

  define_model_callbacks :save, :create
  after_save :check_wallet_warnings
  after_create :check_wallet_warnings

  attribute_method_suffix '_unmask_last'
  define_attribute_methods :account_number

  # override initialize to run callback
  def initialize(params = {})
    run_callbacks :create do
      super
      @cards ||= []
    end
  end

  # create is a new + save returning object
  def self.create(params = {})
    wallet = Wallet.new(params)
    wallet.save
    wallet
  end

  # find wallet by wallet token
  def self.find(wallet_token)
    # we need to make a remote call to get the wallet from our service provider
    # I am skipping the error handling
    response = remote_find(wallet_token)
    wallet = new(response)
    wallet.remotely_saved
  end

  # attributes for serialization interface
  def attributes
    {
        cards_attributes: cards.map(&:attributes),
        wallet_token: wallet_token,
        first_name: first_name,
        last_name: last_name,
        email: email,
        age: age,
        account_number: account_number
    }
  end

  # implement id for conversion module
  def id
    wallet_token
  end

  # implement boolean persisted for conversion module
  def persisted?
    wallet_token ? true : false
  end

  # bulk update of attributes
  def update(params)
    self.attributes = params
    save
  end

  # need this to mimic accepts_nested_attributes_for
  def cards_attributes=(cards)
    @cards = []
    cards.each do |card|
      @cards << Card.new(card)
    end
  end

  # suffix to mask and then unmask the last characters in args[0]
  def attribute_unmask_last(attr, *args)
    args[0] ||= 4
    args[1] ||= 'x'
    content = send(attr)
    return content unless content && content.length > args[0]
    args[1] * (content.length - args[0]) + content[(args[0] * -1)..-1]
  end

  # validation method for cards
  def cards_validation
    if cards.any?(&:invalid?)
      errors[:base] << 'Wallet has an invalid card'
    end
  end

  # do we have any warning messages
  def warning?
    messages && messages.length > 0
  end

  # create warning messages - not enough to invalidate
  def check_wallet_warnings
    @messages = {}
    # do we have cards?
    @messages[:expired_card] = MESSAGES[:expired_card] if cards.any?(&:expired?)
    @messages[:empty_wallet] = MESSAGES[:empty_wallet] if @cards.length < 1
    # always true, dont stop other callbacks
    true
  end

  # delegate find card based on card id
  def find_card(id)
    found_card = nil
    cards.each { |card| found_card = card if card.id == id.to_i }
    found_card
  end

  # delegate change and persist one card
  def update_card(id, params)
    card = find_card(id)
    if card
      card.update(params)
      save
    end
  end

  # delegate delete card
  def destroy_card(id)
    index = index_of_card(id)
    if index
      cards.delete_at(index)
      save
    end
  end

  # save wallet running callbacks
  def save
    run_callbacks :save do
      return false unless valid?
      remote_attributes = remote_save(attributes)
      return false unless remote_attributes
      self.attributes = remote_attributes
      remotely_saved
      true
    end
  end

  # mimic activerecord
  def save!
    return self if save
    fail 'InvalidWallet'
  end

  # update state based on remote save
  def remotely_saved
    cards.each(&:remotely_saved)
    # if we implement Dirty in wallet here is where we will update
    # changes_applied
    self
  end

  # find internal index of card in array
  # todo refactor private
  def index_of_card(id)
    cards.find_index(find_card(id))
  end

  private

  # internal setter for attributes
  def attributes=(params)
    params.each do |attr, value|
      public_send("#{attr}=", value)
    end
    self
  end

end
