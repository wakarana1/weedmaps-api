module Api
  class UsersController < ApplicationController
    before_action :set_user, only: [:show, :update, :destroy]

    def index
      @users = User.all

      render json: @users
    end

    def show
      render json: @user, include: [:medical_recommendation, :identification]
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
      if @user.update(user_params)
        render json: @user, status: :ok
      else
        render json: { errors: @user.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy

      render json: { message: "deleted" }, status: :ok
    end

    private

    def set_user
      begin
        @user = User.includes(:medical_recommendation, :identification).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        user = User.new
        user.errors.add(:id, "Incorrect User ID")
        render json: { errors: user.errors }, status: :not_found
      end
    end

    def user_params
      params.permit(:name, :dob, :email)
    end
  end

end
