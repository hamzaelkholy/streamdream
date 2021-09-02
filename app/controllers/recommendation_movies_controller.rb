require 'open-uri'
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
    if params[:recommendation_movie][:movie_id].length > 7
      # Call the Watchmode api on the movies
      # Which streaming service has the most hits
    else
      # Prompt user to select more
      # Generate new similar movies
      @selected_movies = []
      @results = []
      @movie_ids = params[:recommendation_movie][:movie_id]
      @movie_ids.shift
      # Create array of selected movies (with integers)
      @movie_ids.map do |movie_id|
        @selected_movies << movie_id.to_i
      end
      find_similar_movies # Private method for finding similar movies

    end
  end

  private

  def recommendation_movie_params
    # params.require(:recommendation_movie).permit(:movie_id)
  end

  def find_similar_movies
    @selected_movies.each do |movie_id|
      selected_movie = Movie.find(movie_id)[:title]
      url = "https://tastedive.com/api/similar?q=#{selected_movie}"
      uri = URI.parse(url)
      serialized_search = uri.read
      @results << JSON.parse(serialized_search)["Similar"]["Results"].sample(12 / @selected_movies.length)
    end
  end
end
