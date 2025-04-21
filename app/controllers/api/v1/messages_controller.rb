class Api::V1::MessagesController < ApplicationController

    before_action :authenticate_user!
  
  
        def index
  
              messages = Message.where(client_id: @current_user.client_id)
  
              formatted_messages = messages.map do |mes|
                  {
                    id: mes.id,
                    content: mes.content,
                    senderId: mes.senderId,
                    receiverId: mes.receiverId,
                    timestamp: mes.created_at,
                  }
  
                end
  
              users = User.where(client_id: @current_user.client_id)
  
                formatted_users = users.map do |user|
                  {
                    id: user.id,
                    name: user.name,
                  }
  
              end
  
              render json: {current_user:@current_user, messages: formatted_messages,users:formatted_users }, status: :ok
          
        end

        def add_message
          p "dslldsmfadmfpds",params

          mess = Message.new(
            content: params[:messg][:content],
            senderId: params[:messg][:senderId],
            receiverId: params[:messg][:receiverId],
            client_id: @current_user.client_id,
          )
          if mess.save
            render json: { message: mess }, status: :created
          else
            render json: { errors: mess.errors.full_messages }, status: :unprocessable_entity
          end

      end
  
  
  end