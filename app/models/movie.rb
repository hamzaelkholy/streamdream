class Movie < ApplicationRecord
  has_many :actors, through: :movie_actors
  has_many :streaming_services, through: :availabilities
  has_many :recommendations, through: :recommendation_movies
end
