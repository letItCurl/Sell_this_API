Rails.application.routes.draw do
  post 'user_token' => 'user_token#create'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'ping', to: 'table_tennis#ping'

  concern :api_base do
    resources :classifieds, only: [:show, :index, :create, :update, :destroy] do
      member do
        post 'publications', to: 'classifieds#publish'
      end
    end
    resources :users, only: [:show]
  end

  namespace :v1 do
    concerns :api_base
  end

  namespace :v2 do
    concerns :api_base
  end

end
