class Api::V1::RegistrationsController < ApplicationController

   skip_before_action :authenticate_user!, only: [:create]  

    def create

          # Find or create client
          client = Client.find_or_create_by!(name: params[:user][:cname])

          # Create user and associate client_id
          user = User.new(user_params)
          user.client_id = client.id
          user.client_name = client.name
          user.admin = true
          user.task_creator = true


      if user.save
        token = generate_jwt_token(user)
        render json: { user: user, token: token }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private
  
    def user_params
      params.require(:user).permit(:name,:last_name,:email, :password, :password_confirmation)
    end
  
    def generate_jwt_token(user)
        secret_key = Rails.application.credentials.devise_jwt_secret_key # <-- Use credentials instead of secrets
        JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, secret_key, 'HS256')
    end
    
  end
  