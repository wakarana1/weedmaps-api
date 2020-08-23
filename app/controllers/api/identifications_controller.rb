module Api
  class IdentificationsController < ApplicationController
    before_action :set_identification, only: [:show, :update, :destroy]

    def show
      render json: identification_if_not_expired
    end

    def create
      @identification = Identification.new(identification_params)

      if @identification.save
        render json: identification_if_not_expired, status: :created
      else
        render json: { errors: @identification.errors }, status: :unprocessable_entity
      end
    end

    def update
      if @identification.update(identification_params)
          render json: identification_if_not_expired, status: :ok
      else
        render json: { errors: @identification.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      @identification.destroy

      render json: { message: 'deleted' }, status: :ok
    end

    private
    def identification_params
      params.permit(:user_id, :number, :state, :expiration_date, :image_url)
    end

    def set_identification
      begin
        @identification = Identification.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        identification = Identification.new()
        identification.errors.add(:id, 'Incorrect Identification ID')
        render json: { errors: identification.errors }, status: :not_found
      end
    end

    def identification_if_not_expired
      @identification.expired? ? { message: 'Identification is expired' } : @identification
    end
  end
end
