class ApplicationController < ActionController::API

 before_action :authenticate_user! # ✅ This ensures authentication for protected routes

  # If using JWT authentication, allow token authentication
  include Devise::Controllers::Helpers

  private

  def authenticate_user!
    p "dvfvsfgfdgsfgsgdz"
    token = request.headers['Authorization']&.split(' ')&.last
    return render json: { error: 'Unauthorized' }, status: :unauthorized unless token
    p "dvfvsfgfdgsfgsgdz",token,Rails.application.credentials.devise_jwt_secret_key

    begin
        secret_key = Rails.application.credentials.devise_jwt_secret_key
        token = request.headers['Authorization']&.split(' ')&.last
        p "Token received:", token
        p "JWT Secret Key:", secret_key
      
        decoded_token = JWT.decode(token, secret_key, true, { algorithm: 'HS256' })
        p "Decoded Token:", decoded_token
      
        @current_user = User.find(decoded_token.first['user_id'])
      rescue JWT::ExpiredSignature
        render json: { error: 'Token has expired' }, status: :unauthorized
      rescue JWT::DecodeError => e
        p "JWT Decode Error:", e.message
        render json: { error: 'Invalid Token' }, status: :unauthorized
      end
      
  end

  def current_user
    @current_user
  end
  
end
