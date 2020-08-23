class User < ApplicationRecord
  has_secure_password
  has_one :medical_recommendation, dependent: :destroy
  has_one :identification, dependent: :destroy

  validates_presence_of :name, :email, :dob, :password_digest
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  self.implicit_order_column = 'created_at'
end
