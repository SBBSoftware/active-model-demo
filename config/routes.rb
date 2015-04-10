Rails.application.routes.draw do

  #static home page
  root to: 'pages#show', id: 'index'

  #using high_voltage for static pages
  get '/pages/*id' => 'pages#show', as: :page, format: false

  resource :plain_wallet, :only => [:show, :edit, :update] do
    resources :plain_cards, :except => [:index, :show] #, only: [:edit, :new, :create, :update, :destroy]
  end

  resource :wallet, :only => [:show, :edit, :update] do
    resources :cards #, :except => [:index, :show]
  end


end
