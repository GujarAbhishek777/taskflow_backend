Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root to: proc { [200, {}, ['Rails app is running']] }

  # Handlers for requests arriving without /api/v1 prefix (e.g. if reverse proxy strips /api/v1)
  scope module: 'api/v1' do
    post 'sign_in', to: 'sessions#create'
    delete 'sign_out', to: 'sessions#destroy'
    get 'check_auth', to: 'sessions#check_auth'
    post 'sign_up', to: 'registrations#create'
    get 'users', to: 'users#index'
    post 'add_user', to: 'users#add_user'

    get 'tasks', to: 'tasks#index'
    get 'messages', to: 'messages#index'
    post 'add_message', to: 'messages#add_message'

    post 'add_task', to: 'tasks#add_task'
    get 'tasks_data', to: 'tasks#tasks_data'

    post 'pdf_generator', to: 'pdf_generators#pdf_generator'
  end

  # Handlers for requests arriving with /api/v1 prefix
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

      post 'pdf_generator', to: 'pdf_generators#pdf_generator'
    end
  end
end
