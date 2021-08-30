class StreamingService < ApplicationRecord
  has_many :recommendations
  has_many :movies, through: :availabilities

  validates :name, presence: true, uniqueness: true
end
