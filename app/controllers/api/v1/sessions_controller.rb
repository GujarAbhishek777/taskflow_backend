class Api::V1::SessionsController < Devise::SessionsController
    before_action :authenticate_user!, only: [:check_auth]
    respond_to :json

  
#     private
  
#     def respond_with(resource, _opts = {})
#       render json: { user: resource, token: request.env['warden-jwt_auth.token'] }, status: :ok
#     end
  
#     def respond_to_on_destroy
#       head :no_content
#     end

  def create
    # Ensure `params[:email]` is coming correctly
    user = User.find_by(email: params[:email])

    if user && user.valid_password?(params[:password])
      token = generate_jwt_token(user)
      render json: { user: { id: user.id, email: user.email }, token: token }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def check_auth
    render json: { user: @current_user }, status: :ok
  end

  private

  def generate_jwt_token(user)
    secret_key = Rails.application.credentials.devise_jwt_secret_key
    JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, secret_key, 'HS256')
  end

        

  end
  