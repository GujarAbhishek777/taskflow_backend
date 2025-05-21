class Api::V1::TasksController < ApplicationController

  before_action :authenticate_user!


      def index

            tasks = Task.where(client_id: @current_user.client_id)

            tasks = if @current_user.admin
              tasks # admin sees all tasks
            elsif @current_user.task_creator
              tasks.where("creator = :user_id OR user_id = :user_id", user_id: @current_user.id)
            else
              tasks.where(user_id: @current_user.id)
            end

            formatted_tasks = tasks.map do |task|
                {
                  id: task.id,
                  title: task.title,
                  description: task.description,
                  assignedUser: task.user_name,
                  dueDate: task.due_date,
                  status: task.status,
                }

              end

            users = User.where(client_id: @current_user.client_id)

              formatted_users = users.map do |user|
                {
                  id: user.id,
                  firstName: user.name,
                }

            end

            render json: { tasks: formatted_tasks,users:formatted_users }, status: :ok
        
      end


        def add_task
            p "dslldsmfadmfpds",params

            task = Task.new(
              title: params[:task][:title],
              description: params[:task][:description],
              user_id: params[:task][:assignedUser],
              user_name:User.find(params[:task][:assignedUser].to_i).name,
              due_date: params[:task][:dueDate],
              client_id: @current_user.client_id,
              creator:@current_user.id,
              status: params[:task][:status],
            )
            if task.save
              render json: { task: task }, status: :created
            else
              render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
            end
 
        end

        def tasks_data

          tasks = Task.where(client_id: @current_user.client_id)
          statuses = ['Created', 'In Progress', 'On Hold', 'Cancelled', 'Completed']

          tasks = if @current_user.admin
            tasks # admin sees all tasks
          elsif @current_user.task_creator
            tasks.where("creator = :user_id OR user_id = :user_id", user_id: @current_user.id)
          else
            tasks.where(user_id: @current_user.id)
          end

          formatted_tasks = []

          if params[:from_dash].to_s =="true"

            tasks_data = tasks.order(due_date: :desc).limit(5)
            formatted_tasks = tasks_data.map do |task|
              {
                id: task.id,
                title: task.title,
                description: task.description,
                assignedUser: task.user_name,
                dueDate: task.due_date,
                status: task.status,
              }
            end

          end

          counts = tasks.group(:status).count

          piedata_array = statuses.map { |status| counts[status] || 0 }

          render json: { tasks: formatted_tasks,piedata:piedata_array }, status: :ok

        end
end
  