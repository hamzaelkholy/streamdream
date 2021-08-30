class Actor < ApplicationRecord
  has_many :movies, through: :movie_actors
end
