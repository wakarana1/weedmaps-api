module Api
  class IdentificationsController < ApplicationController
    def show
      @identification = Identification.find(params[:id])

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
      @identification = Identification.find(params[:id])

      if @identification.update(identification_params)
          render json: identification_if_not_expired, status: :ok
      else
        render json: { errors: @identification.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      @identification = Identification.find(params[:id])

      @identification.destroy

      render json: { message: "deleted" }, status: :ok
    end

    private
    def identification_params
      params.permit(:user_id, :number, :state, :expiration_date, :image_url)
    end

    def identification_if_not_expired
      @identification.expired? ? { message: 'Identification is expired' } : @identification
    end
  end
end
