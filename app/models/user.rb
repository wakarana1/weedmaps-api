class User < ApplicationRecord
  has_one :medical_recommendation
  has_one :identification
end
