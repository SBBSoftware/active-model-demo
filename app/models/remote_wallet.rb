# table backed model to simulate remote server storage
class RemoteWallet < ActiveRecord::Base

  has_many :cards, -> { order(id: :asc) },
           foreign_key: 'remote_wallet_id',
           class_name: 'RemoteCard',
           dependent: :destroy

  # callback to create a unique card token on save
  before_validation :generate_token

  accepts_nested_attributes_for :cards, allow_destroy: true

  validates :wallet_token, :email, presence: true
  validates :email, format: { with: /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/ }
  validates :wallet_token, uniqueness: true

  # todo extract this into a concern but left here for clarity
  def generate_token
    self.wallet_token = SecureRandom.uuid unless wallet_token
  end

  # to simplify remote api, all updates will be create_or_update with destroy
  # only cards sent will be saved, all other cards will be deleted
  def self.create_or_update(wallet_token, params)
    existing_wallet = RemoteWallet.find_by_wallet_token(wallet_token)
    params.recursive_symbolize_keys! # i really hate this but need consistency
    if existing_wallet
      # remove card attributes from params
      card_params = params.delete(:cards_attributes)
      # put all the card tokens in an array
      card_tokens = card_params.map { |x| x[:card_token] }
      # remove all cards not in the card_tokens array
      existing_wallet.cards.each do |card|
        card.delete unless card_tokens.include?(card.card_token)
      end
      # need to go through each card and update
      card_params.each do |card_param|
        card = existing_wallet.cards.find_by(card_token: card_param[:card_token])
        # update or create
        if card
          card.update(card_param)
        else
          # create a new card from scratch
          existing_wallet.cards.create(card_param)
        end
      end
      # finally update the wallet should save all
      result = existing_wallet.update(params)
      fail ActiveRecord::RecordInvalid, existing_wallet unless result
      existing_wallet.reload
      existing_wallet
    else
      RemoteWallet.create!(params)
    end
  end

  # return a default wallet so that we never need to create a new one
  def self.default_wallet(wallet_token)
    existing_wallet = find_by_wallet_token(wallet_token)
    if existing_wallet.nil?
      mock_attributes = MOCK_WALLET.clone
      mock_attributes[:wallet_token] = wallet_token
      mock_attributes[:cards_attributes].each_with_index { |card, index| card[:card_token] = "#{wallet_token}-TOK-#{index + 1}" }
      existing_wallet = create(mock_attributes)
    end
    existing_wallet
  end

end
