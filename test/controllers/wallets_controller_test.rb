require 'test_helper'
class WalletsControllerTest < ActionController::TestCase

  context 'GET #show' do
    setup { get :show }
    should render_template('show')
    should respond_with :success
  end

  context 'GET #edit' do
    setup { get :edit }
    should render_template('edit')
    should render_template(partial: '_form')
    should respond_with :success
  end

  context 'PATCH #update' do
    setup do
      get :edit
      patch :update, wallet: { first_name: 'Changed', last_name: 'In', email: 'controller_test@test.com' }
    end
    should redirect_to(action: :show)
  end

end
