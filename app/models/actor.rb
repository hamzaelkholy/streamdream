class Actor < ApplicationRecord
  has_many :movies, through: :movie_actors

  validates :name, presence: true, uniqueness: true
end
