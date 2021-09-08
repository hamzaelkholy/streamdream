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
      "Netflix" => 203,
      "Disney Plus" => 372,
      "Hulu" => 157,
      "HBO" => 360,
      "HBO NOW" => 146,
      "Amazon Prime" => 26,
      "AppleTV+" => 371,
      "HBO Max" => 387,
      "Peacock" => 389,
      "Crackle" => 77,
      "Youtube Premium" => 369,
      "Discovery+" => 445
    }
    @selected_movies = params[:recommendation_movie][:movie_id]
    @selected_movies += params[:recommendation_movie][:already_selected].split(' ') if params.dig(:recommendation_movie, :already_selected).present?

    if @selected_movies.length > 7
      # # Call the Watchmode api on the movies
      @selected_movies.each do |movie_id|
        selected_movie = Movie.find(movie_id)[:imdb_id]
        # Call Watchmode API to find the Watchmode id of a imdb_id (get_watchmode_id(selected_movie))
        # THIS IS THE WATCHMODE ID (result_watchmode_search["title_results"][0]["id"])
        get_watchmode_id(selected_movie)
        # Call Watchmode API using ID to find the streaming service of a
        uri_2 = URI("https://api.watchmode.com/v1/title/#{get_watchmode_id(selected_movie)["title_results"][0]["id"]}/sources/?apiKey=#{ENV['WATCHMODE_API_KEY']}")
        service_json = Net::HTTP.get(uri_2)
        watchmode_service_list = JSON(service_json)

        # Array of all found streaming services
        @service_source_ids = []

        # Get the source_id for each movie
        watchmode_service_list.each do |service|
          @service_source_ids << service["source_id"] if service["type"] == 'sub'
        end
      end
      # Count the streaming service hits
      counted_service = @service_source_ids.inject(Hash.new(0)) { |total, id| total[id] += 1; total }

      # Get streaming service with most hits
      recommendation_service = @stream_hash.key(counted_service.max_by { |_, v| v }[0])
      # Which streaming service has the most hits
      @recommendation_movie = RecommendationMovie.new(network: recommendation_service)
      stats # method to get the year, director and genres
      redirect_to results_path(results: { streaming_services: counted_service, movies: @selected_movies, statistics: @stats })
    else
      @results = []
      # Find the movie id's and make them integer
      @movie_ids = params[:recommendation_movie][:movie_id]
      # Create array of selected movies
      @movie_ids.map!(&:to_i)

      find_similar_movies # Private method for finding similar movies

      similar_movies_ids = []
      @movies.each { |movie| similar_movies_ids << movie.id }

      # Give similar movies to the param for next page load
      redirect_to new_recommendation_movie_path(ids: similar_movies_ids, selected_movies: @selected_movies)
    end
  end

  def show_results
    @recommendation_movies = current_user.recommendation_movies
  end

  private

  def find_similar_movies
    @movie_ids.each do |movie_id|
      # Call similar movie API
      selected_movie = Movie.find(movie_id)[:title]
      url = "https://tastedive.com/api/similar?q=#{selected_movie}"
      uri = URI.parse(url)
      serialized_search = uri.read
      @results << JSON.parse(serialized_search)["Similar"]["Results"].sample(6)
      @results.flatten!
      # Create Movie Object
      create_movie(@results.sample(6))
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



  def stats
    @stats = {
      genres: [],
      directors: [],
      dates_released: []
    }
    # @selected_movies = params[:results][:movies]
    @selected_movies.each do |movie|
      current_movie = Movie.find(movie)
      @stats[:genres] << current_movie.genre.split(",")
      @stats[:directors] << current_movie.director
      @stats[:dates_released] << current_movie.date_released.to_i
      @stats[:genres].flatten!
    end
    @genres_and_occurences = @stats[:genres].inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}
    @genre_occurences = @stats[:genres].inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}.values
    @most_genre = @stats[:genres].inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}.key(@genre_occurences.max)

    @directors_and_occurences = @stats[:directors].inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}
    @director_occurences = @stats[:directors].inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}.values
    @most_director = @stats[:directors].inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}.key(@director_occurences)

    return @stats
  end
end
