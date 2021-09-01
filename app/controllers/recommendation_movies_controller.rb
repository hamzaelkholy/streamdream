class RecommendationMoviesController < ApplicationController
  def new
    @recommendation_movie = RecommendationMovie.new
    @movies_sample = Movie.all.sample(10)
    @movies_sample.each do |movie|
      movie.poster_url = 'https://m.media-amazon.com/images/M/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_SX300.jpg'
    end
  end

  def create
    @recommendation_movie = RecommendationMovie.new(recommendation_movie_params)
    raise
  end

  private

  def recommendation_movie_params
    params.require(:recommendation_movie).permit(:movie_id)
  end
end
