module Api
  class UsersController < ApplicationController
    def index
      @users = User.all

      render json: @users
    end

    def show
      @user = User.find(params[:id])
      render json: @user
    end

    def create
      @user = User.new(user_params)

      if @user.save
        render json: @user, status: :created
      else
        render json: { errors: @user.errors }, status: :unprocessable_entity
      end
    end

    def update
      @user = User.find(params[:id])

      if @user.update(user_params)
        render json: @user, status: :ok
      else
        render json: { errors: @user.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      @user = User.find(params[:id])

      @user.destroy

      render json: { message: "deleted" }, status: :ok
    end

    private
    def user_params
      params.permit(:name, :dob, :email)
    end
  end

end
