class MedicalRecommendation < ApplicationRecord
  belongs_to :user

  validates_presence_of :number, :issuer, :state, :expiration_date, :image_url, :user_id

  def expired?
    expiration_date < Date.today
  end
end
