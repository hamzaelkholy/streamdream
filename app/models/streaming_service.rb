class StreamingService < ApplicationRecord
  has_many :recommendations
  has_many :availabilities
  has_many :movies, through: :availabilities
end
