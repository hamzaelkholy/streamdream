require 'open-uri'
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
    @selected_movies = @selected_movies + params[:recommendation_movie][:already_selected].split(' ') if params.dig(:recommendation_movie, :already_selected).present?

    if @selected_movies.length > 7
      # Call the Watchmode api on the movies
      # Which streaming service has the most hits
      redirect_to results_path
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

  def results
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

  def show
    @reccomendation_movies = ReccomendationMovies.find(params[:id]) if params[:id]
  end

end
