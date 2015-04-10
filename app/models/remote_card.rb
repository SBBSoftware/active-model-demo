# table backed model to simulate remote server storage
class RemoteCard < ActiveRecord::Base

  belongs_to :remote_wallet

  # callback to create a unique card token on save
  before_validation :generate_token

  validates :card_type, :card_number, :expiration_date, :card_token, presence: true
  validates :card_token, uniqueness: true
  validates :card_number, length: { in: 13..16 }
  validates :card_type, inclusion: { in: %w( VISA MASTERCARD AMEX ) }

  scope :as_added, -> { order(id: :asc) }

  # todo extract this into a concern but left here for clarity
  def generate_token
    self.card_token = SecureRandom.uuid unless card_token && card_token.length > 0
  end

  def first_6
    return nil unless card_number && card_number.length > 12
    card_number[0..6]
  end

  def last_4
    return nil unless card_number && card_number.length > 12
    card_number[-4..-1]
  end

end
