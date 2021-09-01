class RecommendationMoviesController < ApplicationController
  def new
    @recommendation_movie = RecommendationMovie.new
  end

  def create
    @recommendation_movie = RecommendationMovie.new(recommendation_movie_params)
    if params[:recommendation_movie][:movie_id].length > 7
      # Call the Watchmode api on the movies
      # Which streaming service has the most hits
    else
      # Prompt user to select more
      # Generate new similar movies
      @selected_movies = []
      @movie_ids = params[:recommendation_movie][:movie_id]
      @movie_ids.shift
      # Create array of selected movies (with integers)
      @movie_ids.map do |movie_id|
        @selected_movies << movie_id.to_i
      end

    end
  end

  private

  def recommendation_movie_params
    # params.require(:recommendation_movie).permit(:movie_id)
  end
end
