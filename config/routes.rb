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
      get 'users', to: 'users#index'
      post 'add_user', to: 'users#add_user'

      get 'tasks', to: 'tasks#index'
      get 'messages', to: 'messages#index'
      post 'add_message', to: 'messages#add_message'

      post 'add_task', to: 'tasks#add_task'
      get 'tasks_data', to: 'tasks#tasks_data'
      



      # resources :tasks, only: [:index, :create]
    end
  end

  
end
