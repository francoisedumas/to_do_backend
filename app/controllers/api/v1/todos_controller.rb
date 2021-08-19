module Api
  module V1
    class TodosController < ApplicationController
      before_action :set_todo, only: [:show, :update, :destroy]
      MAX_PAGINATION_LIMIT = 100

      # GET /todos
      def index
        # here the limit into bracket is a function define in the private section
        @todos = Todo.limit(limit).offset(params[:offset])

        render json: TodosRepresenter.new(@todos).as_json.reverse
      end

      # GET /todos/1
      def show
        render json: @todo
      end

      # POST /todos
      def create
        @todo = Todo.new(todo_params)

        if @todo.save
          render json: TodoRepresenter.new(@todo).as_json, status: :created
        else
          render json: @todo.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /todos/1
      def update
        if @todo.update(todo_params)
          render json: @todo
        else
          render json: @todo.errors, status: :unprocessable_entity
        end
      end

      # DELETE /todos/1
      def destroy
        @todo.destroy

        head :no_content
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_todo
        @todo = Todo.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def todo_params
        params.require(:todo).permit(:id, :title, :completed, :_limit)
      end

      def limit
        [
          params.fetch(:_limit, MAX_PAGINATION_LIMIT).to_i,
          MAX_PAGINATION_LIMIT
        ].min
      end
    end
  end
end
