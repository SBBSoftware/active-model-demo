require 'test_helper'
class PlainCardsControllerTest < ActionController::TestCase

  context 'GET #new' do
    setup { get :new }
    should render_template('new')
  end

  context 'POST #create' do
    setup do
      post :create, plain_card: { card_number: '1234123412341234', card_type: 'VISA', expiration_date: Date.today + 1 }
    end
    should redirect_to(Rails.application.routes.url_helpers.plain_wallet_path)
  end

  context 'GET #edit' do
    setup do
      get :edit, id: 1
    end
    should render_template('edit')
    should render_template(partial: '_form')
    should respond_with :success
  end

  context 'PATCH #update' do
    setup do
      patch :update, id: 1, plain_card: { card_number: '1234123412341234', card_type: 'VISA', expiration_date: Date.today + 1 }
    end
    should redirect_to(Rails.application.routes.url_helpers.plain_wallet_path)
  end

  context 'DELETE #destroy' do
    setup do
      delete :destroy, id: 1
    end
    should redirect_to(Rails.application.routes.url_helpers.plain_wallet_path)
  end

end
