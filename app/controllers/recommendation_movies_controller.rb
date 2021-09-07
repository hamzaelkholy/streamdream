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
    @networks = []
    @stats = {
      genres: [],
      directors: [],
      dates_released: []
    }
    @stream_hash = {
      203 => "Netflix",
      372 => "Disney Plus",
      157 => "Hulu",
      360 => "HBO",
      146 => "HBO NOW",
      26 => "Amazon Prime",
      371 => "AppleTV+",
      387 => "HBO Max",
      389 => "Peacock",
      77 => "Crackle",
      369 => "Youtube Premium",
      445 => "Discovery+"
    }
    @selected_movies = params[:recommendation_movie][:movie_id]
    @selected_movies += params[:recommendation_movie][:already_selected].split(' ') if params.dig(:recommendation_movie, :already_selected).present?
    if @selected_movies.length > 8
      # # Call the Watchmode api on the movies
      @selected_movies.shift
      @selected_movies.each do |movie_id|
        selected_movie = Movie.find(movie_id)[:imdb_id]
        # Call Watchmode API to find the Watchmode id of a imdb_id (get_watchmode_id(selected_movie))
        # THIS IS THE WATCHMODE ID (result_watchmode_search["title_results"][0]["id"])
        get_watchmode_id(selected_movie)
        raise
        # Call Watchmode API using ID to find the streaming service of a
        uri_2 = URI("https://api.watchmode.com/v1/title/#{get_watchmode_id(selected_movie)["title_results"][0]["id"]}/sources/?apiKey=#{ENV['WATCHMODE_API_KEY']}")
        json_2 = Net::HTTP.get(uri_2)
        result_watchmode_title = JSON(json_2)
      end
      # Which streaming service has the most hits
      RecommendationMovie.new(network: @stream_hash.to_a.sample(1).to_h.values[0])
      stats
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
      redirect_to new_recommendation_movie_path(ids: similar_movies_ids, selected_movies: @selected_movies)
    end
  end

  private

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

  def get_watchmode_id(selected_movie)
    uri = URI("https://api.watchmode.com/v1/search/?apiKey=#{ENV['WATCHMODE_API_KEY']}&search_field=imdb_id&search_value=#{selected_movie}")
    json = Net::HTTP.get(uri)
    result_watchmode_search = JSON(json)
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

  def show
    @reccomendation_movies = ReccomendationMovies.find(params[:id]) if params[:id]
  end

  def stats
    @selected_movies.each do |movie|
      current_movie = Movie.find(movie)
      @stats[:genres] << current_movie.genre.split(",")
      @stats[:directors] << current_movie.director
      @stats[:dates_released] << current_movie.date_released.to_i
      @stats[:genres].flatten!
    end

    @genres_and_occurences = @stats[:genres].inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}
    @genre_occurences = @stats[:genres].inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}.values
    @most_genre = @stats[:genres].inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}.key(@genre_occurences)

    @directors_and_occurences = @stats[:directors].inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}
    @director_occurences = @stats[:directors].inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}.values
    @most_director = @stats[:directors].inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}.key(@director_occurences)
  end

end
