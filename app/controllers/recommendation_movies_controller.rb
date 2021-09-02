require 'open-uri'
class RecommendationMoviesController < ApplicationController
  def new
    @recommendation_movie = RecommendationMovie.new
    # if params[:ids].any?
    #   @movies_sample = params[:results]
    # else
    @movies_sample = Movie.all.sample(12)
    # end
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
      session[:results] = @results
      raise
      redirect_to new_recommendation_movie_path
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
      @results.flatten!
      create_movie(@results)
    end
  end

  def create_movie(results)
    # Store movie instances
    @movies = []
    results.each do |movie|
      # Call Omdb API for updating movie model
      omdb_url = "http://www.omdbapi.com/?t=#{movie["Name"]}&apikey=#{ENV['OMDB_KEY']}"
      .unicode_normalize(:nfkd)
      .encode('ASCII', replace: '')

      omdb_api = URI.open(omdb_url).string
      omdb_json = JSON.parse(omdb_api)

      # Create movie object
      @movies << Movie.create!(
        title: omdb_json['Title'],
        genre: omdb_json['Genre'][0],
        date_released: omdb_json['Year'],
        director: omdb_json['Director'],
        description: omdb_json['Plot'],
        poster_url: omdb_json["Poster"],
        rating: omdb_json['imdbRating'].to_i
      )
    end
  end
end
