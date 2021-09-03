class StreamingService < ApplicationRecord
  has_many :availabilities
  has_many :movies, through: :availabilities

  validates :name, presence: true, uniqueness: true
end
