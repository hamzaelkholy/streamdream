class Movie < ApplicationRecord
  has_many :movie_actors
  has_many :actors, through: :movie_actors
  has_many :availabilities
  has_many :streaming_services, through: :availabilities
  has_many :recommendation_movies
  has_many :recommendations, through: :recommendation_movies
end
