class RecommendationMoviesController < ApplicationController
  def new
    @recommendation_movie = RecommendationMovie.new
  end

  def create
  end
end
