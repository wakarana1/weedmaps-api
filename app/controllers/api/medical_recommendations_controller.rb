module Api
  class MedicalRecommendationsController < ApplicationController
    before_action :set_med_rec, only: [:show, :update, :destroy]

    def show
      render json: med_rec_if_not_expired
    end

    def create
      @user = User.find(params[:user_id])
      @med_rec = new_or_update(@user)

      if @med_rec.save
        render json: med_rec_if_not_expired, status: :created
      else
        render json: { errors: @med_rec.errors }, status: :unprocessable_entity
      end
    end

    def update
      if @med_rec.update(med_rec_params)
          render json: med_rec_if_not_expired, status: :ok
      else
        render json: { errors: @med_rec.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      @med_rec.destroy

      render json: { message: "deleted" }, status: :ok
    end

    private
    def med_rec_params
      params.permit(:user_id, :number, :issuer, :state, :expiration_date, :image_url)
    end

    def set_med_rec
      begin
        @med_rec = MedicalRecommendation.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        med_rec = MedicalRecommendation.new()
        med_rec.errors.add(:id, "Incorrect Medical Recommendation ID")
        render json: { errors: med_rec.errors }, status: :not_found
      end
    end

    def new_or_update(user)
      if user.medical_recommendation
        med_rec = user.medical_recommendation
        med_rec.attributes = med_rec_params
      else
        med_rec = MedicalRecommendation.new(med_rec_params)
      end
      med_rec
    end

    def med_rec_if_not_expired
      @med_rec.expired? ? { message: 'Medical Recommendation is expired' } : @med_rec
    end
  end
end
