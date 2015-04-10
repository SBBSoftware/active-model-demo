require 'test_helper'
class CardsControllerTest < ActionController::TestCase

  context 'GET #new' do
    setup { get :new }
    should render_template('new')
  end

  context 'POST #create' do
    setup do
      post :create, card: { card_number: '1234123412341234', card_type: 'VISA', short_expiration: '01/20' }
    end
    should redirect_to(Rails.application.routes.url_helpers.wallet_path)
  end

  context 'GET #edit' do
    setup do
      wallet = Wallet.find(session.id)
      get :edit, id: wallet.cards.first.id
    end
    should render_template('edit')
    should render_template(partial: '_form')
    should respond_with :success
  end

  context 'PATCH #update' do
    setup do
      wallet = Wallet.find(session.id)
      patch :update, id: wallet.cards.first.id, card: { card_number: '1234123412341234', card_type: 'VISA', short_expiration: '01/20' }
    end
    should redirect_to(Rails.application.routes.url_helpers.wallet_path)
  end

  context 'DELETE #destroy' do
    setup do
      wallet = Wallet.find(session.id)
      delete :destroy, id: wallet.cards.first.id
    end
    should redirect_to(Rails.application.routes.url_helpers.wallet_path)
  end
end
