class Api::V1::UsersController < ApplicationController

    before_action :authenticate_user!

    def index
      users = User.where(client_id: @current_user.client_id)

        formatted_users = users.map do |user|
          {
            id: user.id,
            firstName: user.name,
            lastName: user.last_name,
            email: user.email,
            designation: user.designation,
            admin: user.admin,
            task_creator: user.task_creator
          }

        end

      render json: { users: formatted_users }, status: :ok
      
    end
 
    def add_user
      p "aaaaaaaaaaaaaaaaaaaa",@current_user
        user = User.new(
          name: params[:firstName],
          last_name: params[:lastName],
          email: params[:email],
          designation: params[:designation],
          admin: params[:admin],
          client_id: @current_user.client_id,
          client_name: @current_user.client_name ,
          password: "Sumal@777",
          password_confirmation: "Sumal@777",
          task_creator: params[:admin].to_s == "true" ? true : params[:task_creator] 
        )

        if user.save
          render json: { user: user }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

end
   