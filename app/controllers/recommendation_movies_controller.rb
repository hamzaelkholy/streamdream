require 'open-uri'
class RecommendationMoviesController < ApplicationController
  def new
    @recommendation_movie = RecommendationMovie.new
    # Render form with Data from DB if no params available
    if params[:format].nil?
      @movies_sample = Movie.all.sample(12)
    else
      @movies_sample = []
      params[:format].split('/') do |id|
        @movies_sample << Movie.find(id)
      end
    end
  end

  def create
    @recommendation_movie = RecommendationMovie.new(recommendation_movie_params)
    if params[:recommendation_movie][:movie_id].length > 7
      # Call the Watchmode api on the movies
      # Which streaming service has the most hits
    else
      # Don't empty array unless it's new recommendation_movie
      if params[:ids].nil?
        @selected_movies = []
      end
      @results = []
      # Find the movie id's and make them integer
      @movie_ids = params[:recommendation_movie][:movie_id]
      @movie_ids.shift
      # Create array of selected movies
      @movie_ids.map do |movie_id|
        @selected_movies << movie_id.to_i
      end
      find_similar_movies # Private method for finding similar movies
      movie_ids = []
      @movies.each do |movie|
        movie_ids << movie.id
      end
      params[:ids] = movie_ids
      redirect_to new_recommendation_movie_path(params[:ids])
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
      @results << JSON.parse(serialized_search)["Similar"]["Results"].sample(6 / @selected_movies.length)
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
    @movies << Movie.all.sample(6)
    @movies.flatten!
  end
end
