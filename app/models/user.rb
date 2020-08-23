class User < ApplicationRecord
  has_secure_password
  has_one :medical_recommendation, dependent: :destroy
  has_one :identification, dependent: :destroy

  validates_presence_of :name, :email, :dob, :password_digest
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  HIDDEN_FIELDS = [
    'password_digest',
    'encrypted_password',
    'reset_password_token',
    'reset_password_sent_at',
    'remember_created_at'
  ]

  self.implicit_order_column = 'created_at'

  default_scope { select(User.column_names - HIDDEN_FIELDS) }

end
