class User < ApplicationRecord
  has_one :medical_recommendation, dependent: :destroy
  has_one :identification, dependent: :destroy

  validates_presence_of :name, :email, :dob
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
