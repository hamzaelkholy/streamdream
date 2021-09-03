require 'open-uri'
require 'net/http'
require 'uri'
require 'json'

class RecommendationMoviesController < ApplicationController
  def new
    @recommendation_movie = RecommendationMovie.new
    # Render form with Data from DB if no params available
    if params[:ids].nil?
      @movies_sample = Movie.all.sample(12)
      @selected_movies = []
    else
      @selected_movies = params[:selected_movies]
      @movies_sample = []
      params[:ids].each do |id|
        @movies_sample << Movie.find(id)
      end
    end
  end
  def create
    @recommendation_movie = RecommendationMovie.new(recommendation_movie_params)
    @selected_movies = params[:recommendation_movie][:movie_id]
    @selected_movies += params[:recommendation_movie][:already_selected].split(' ') if params.dig(:recommendation_movie, :already_selected).present?

    if @selected_movies.length > 7
      # Call the Watchmode api on the movies
      # @selected_movies.shift
      # @selected_movies.each do |movie_id|
      #   selected_movie = Movie.find(movie_id)[:imdb_id]
      #   # Call Watchmode API to find the Watchmode id of a title
      #   uri = URI("https://api.watchmode.com/v1/search/?apiKey=#{ENV['WATCHMODE_API_KEY']}&search_field=imdb_id&search_value=#{selected_movie}")

      #   json = Net::HTTP.get(uri)
      #   result_watchmode_search = JSON(json)
      #   # THIS IS THE WATCHMODE ID (result_watchmode_search["title_results"][0]["id"])
      #   # Call Watchmode API using ID to find the streaming service of a
      #   uri_2 = URI("https://api.watchmode.com/v1/title/#{result_watchmode_search["title_results"][0]["id"]}/details/?apiKey=#{ENV['WATCHMODE_API_KEY']}")
      #   json_2 = Net::HTTP.get(uri_2)
      #   result_watchmode_title = JSON(json_2)
      #   result_watchmode_title["networks"]

      #   # Create recommendation_movie instance and redirect to result (show page)
      # end
      @recommendation_movie = RecommendationMovie.new(network: 'netflix')
      redirect_to recommendation_movie_path(@recommendation_movie)
      # Which streaming service has the most hits
    else
      @results = []
      # Find the movie id's and make them integer
      @movie_ids = params[:recommendation_movie][:movie_id]
      @movie_ids.shift
      # Create array of selected movies
      @movie_ids.map!(&:to_i)

      find_similar_movies # Private method for finding similar movies

      similar_movies_ids = []
      @movies.each { |movie| similar_movies_ids << movie.id }

      # Give similar movies to the param for next page load
      # raise
      redirect_to new_recommendation_movie_path(ids: similar_movies_ids, selected_movies: @selected_movies)
    end
  end

  private

  def recommendation_movie_params
    # params.require(:recommendation_movie).permit(:movie_id)
  end

  def find_similar_movies
    @movie_ids.each do |movie_id|
      # Call similar movie API
      selected_movie = Movie.find(movie_id)[:title]
      url = "https://tastedive.com/api/similar?q=#{selected_movie}"
      uri = URI.parse(url)
      serialized_search = uri.read
      @results << JSON.parse(serialized_search)["Similar"]["Results"].sample(6 / @movie_ids.length)
      @results.flatten!
      # Create Movie Object
      create_movie(@results)
    end
  end

  def create_movie(results)
    # Store movie instances
    @movies = []
    results.each do |movie|
      # Check if movie is in DB
      if Movie.find_by(title: movie["Name"]).nil?
        # Call Omdb API for updating movie model
        omdb_url = "http://www.omdbapi.com/?t=#{movie["Name"]}&apikey=#{ENV['OMDB_KEY']}"
        .unicode_normalize(:nfkd)
        .encode('ASCII', replace: '')

        omdb_api = URI.open(omdb_url).string
        omdb_json = JSON.parse(omdb_api)

        # Create movie object
        @movies << Movie.create!(
          title: omdb_json['Title'],
          genre: omdb_json['Genre'],
          date_released: omdb_json['Year'],
          director: omdb_json['Director'],
          description: omdb_json['Plot'],
          poster_url: omdb_json["Poster"],
          imdb_id: omdb_json["imdbID"],
          rating: omdb_json['imdbRating'].to_i
        )
      else
        @movies << Movie.find_by(title: movie["Name"])
      end
    end
    # Add 6 random movies
    @movies << Movie.all.sample(6)
    @movies.flatten!
  end

  def selected_movies_integer_array
    # @movie_ids = params[:recommendation_movie][:movie_id]
    # @movie_ids.shift
    @selected_movies.shift
    @movie_ids.map do |movie_id|
      @selected_movies << movie_id.to_i
    end
    @selected_movies
  end

end
