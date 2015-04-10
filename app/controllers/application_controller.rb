class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: :json_request?

  protected

  def json_request?
    request.format.json?
  end

  def set_plain_wallet
    # in the real world we'd need a user to access a wallet
    # with single resource we are going to simulate with the session
    if json_request?
      authenticate_or_request_with_http_token do |token|
        @plain_wallet = PlainWallet.find(token)
      end
    else
      @plain_wallet = PlainWallet.find(session.id)
    end
  end

  def set_wallet
    # in the real world we'd need a user to access a wallet
    # with single resource we are going to simulate with the session
    if json_request?
      authenticate_or_request_with_http_token do |token|
        @wallet = Wallet.find(token)
      end
    else
      @wallet = Wallet.find(session.id)
    end
  end
end
