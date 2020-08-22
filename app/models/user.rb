class User < ApplicationRecord
  has_one :medical_recommendation
  has_one :identification

  validates_presence_of :name, :email, :dob
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
