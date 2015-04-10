require 'test_helper'

class RegistrationTest < ActiveSupport::TestCase


  should 'be valid when password and password confirmation match' do
    params = attributes_for(:valid_registration)
    reg = Registration.new(params)
    assert reg.valid?
  end

  should 'be invalid if confirmation and password do not match' do
    params = attributes_for(:valid_registration)
    params[:password_confirmation] = 'iamnotcorrect'
    reg = Registration.new(params)
    refute reg.valid?
  end

  should 'always require password and password confirmation to be set' do
    params = attributes_for(:valid_registration)
    params.delete(:password_confirmation)
    reg = Registration.new(params)
    refute reg.valid?
  end

  should 'require minimum of 6 characters' do
    params = attributes_for(:valid_registration)
    params[:password_confirmation] = '12345'
    params[:password] = '12345'
    reg = Registration.new(params)
    refute reg.valid?
  end

  # refactored out with additional validation
  # should 'not need password_confirmation if it is never set' do
  #   params = attributes_for(:valid_registration)
  #   params.delete(:password_confirmation)
  #   reg = Registration.new(params)
  #   assert reg.valid?
  # end

  should 'authenticate on valid password' do
    reg = create(:valid_registration)
    result = reg.authenticate('password1')
    assert result
  end

  should 'not authenticate on invalid password' do
    reg = create(:valid_registration)
    result = reg.authenticate('iamnotapassword')
    refute result
  end

end
