Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'identity#auth'
  post '/auth/:provider/callback', to: 'identity#auth'

  namespace :v1 do
    get '/translation', to: 'translations#show'
    get '/global_settings', to: 'global_settings#index'

    get '/auth', to: 'auth#check'
    post '/auth', to: 'auth#auth'

    resource :user, only: %i[create update show destroy], controller: :user do
      member do
        post 'confirm_email', to: 'user#confirm_email'
        post 'forgot_password', to: 'auth#request_password_reset'
        post 'reset_password', to: 'auth#reset_password'
      end
    end

    resources :widgets
  end

  get 'confirm_email/:token', to: 'v1/user#confirm_email'

  require 'sidekiq/web'
  constraints CanAccessSidekiq.new do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # mount ActionCable.server => '/cable'
end
