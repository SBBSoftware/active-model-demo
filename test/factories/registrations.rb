FactoryGirl.define do

  factory :valid_registration, class: Registration do
    skip_create
    first_name 'Gabriel'
    last_name 'Conroy'
    user_name 'GC'
    password 'password1'
    password_confirmation 'password1'
  end


end
