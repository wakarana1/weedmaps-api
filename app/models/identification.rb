class Identification < ApplicationRecord
  belongs_to :user
  validates_presence_of :number, :state, :expiration_date, :image_url, :user_id
end
