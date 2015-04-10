# mock wallet with storage in local tables
module RemoteSbbWalletDelegate
  extend ActiveSupport::Concern
  module ClassMethods
    # find wallet on remote server by token
    def remote_find(wallet_token)
      wallet = RemoteWallet.find_by_wallet_token(wallet_token)
      # get default wallet if none exists. cheating cheating cheating
      wallet = RemoteWallet.default_wallet(wallet_token) unless wallet
      # need to convert the remote object
      convert_remote_wallet(wallet)
    end

    def convert_remote_wallet(wallet)
      params = wallet.attributes
      # we don't want to send internal ids
      params.delete('id')
      # we want to get all cards
      params['cards_attributes'] = []
      wallet.cards.each do |card|
        params['cards_attributes'] << convert_remote_card(card)
      end
      params
    end

    def convert_remote_card(card)
      params = card.attributes
      params.delete('id')
      params.delete('remote_wallet_id')
      params.delete('card_number')
      params['last_4'] = card.last_4
      params['first_6'] = card.first_6
      params
    end
  end

  def convert_local_wallet(wallet)
    wallet[:cards_attributes].each do |card|
      convert_local_card(card)
    end
    wallet
  end

  def convert_local_card(card)
    card.delete(:last_4)
    card.delete(:first_6)
    # this should probably be in the local model
    card.delete(:card_number) unless card[:card_number]
  end

  def remote_save(local_params)
    # erase local items which should not be stored
    # real 3rd party services may require a great deal more marshalling
    # enough to extract out to another concern
    convert_local_wallet(local_params)
    # make the remote api call
    remote_wallet = RemoteWallet.create_or_update(local_params[:wallet_token], local_params)
    # now return the saved wallet
    self.class.convert_remote_wallet(remote_wallet)
    # remote_wallet.remote_attributes
  end
end
