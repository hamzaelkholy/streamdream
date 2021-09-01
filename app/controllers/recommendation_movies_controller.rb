class RecommendationMoviesController < ApplicationController
  def new
    @recommendation_movie = RecommendationMovie.new
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
