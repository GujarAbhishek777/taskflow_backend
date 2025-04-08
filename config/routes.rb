Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      devise_for :users, path: '', controllers: {
        sessions: 'api/v1/sessions',
      }
      
      devise_scope :user do
        get "/check_auth", to: "sessions#check_auth"
      end
      post 'sign_up', to: 'registrations#create'

      # resources :tasks, only: [:index, :create]
    end
  end

  
end
