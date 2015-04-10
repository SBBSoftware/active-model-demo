#monkey monkey
class Hash
  def recursive_symbolize_keys!
    symbolize_keys!
    # symbolize each hash in .values
    values.each { |h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    # symbolize each hash inside an array in .values
    values.select { |v| v.is_a?(Array) }.flatten.each { |h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    self
  end
end

MESSAGES = {

    expired_card: 'Your wallet contains an expired card',
    empty_wallet: 'You have no payment options on file'


}

MOCK_WALLET = {
    first_name: 'Billy',
    last_name: 'Budd',
    email: 'bill.budd@test.com',
    age: 32,
    account_number: '123456789',
    cards_attributes: [
        { expiration_date: Date.today + 50, card_number: '1234560000001234', card_type: 'VISA' },
        { expiration_date: Date.today + 150, card_number: '7890120000005678', card_type: 'MASTERCARD' },
        { expiration_date: Date.today - 1, card_number: '3456780000009012', card_type: 'AMEX' }
    ]
}