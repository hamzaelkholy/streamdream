require 'faker'
require 'csv'
require "uri"
require 'json'

csv_options = { col_sep: ',', quote_char: '"', headers: :first_row }

url = 'https://github.com/peetck/IMDB-Top1000-Movies/blob/master/IMDB-Movie-Data.csv'
genres = ["action", "fantasy", "sci-fi", "horror", "romantic comedies", "comedies"]

puts 'Cleaning the database'
MovieActor.destroy_all
Actor.destroy_all
Availability.destroy_all
RecommendationMovie.destroy_all
Movie.destroy_all
StreamingService.destroy_all
User.destroy_all

puts 'Creating the seeds'

puts 'Creating movies...'

filepath = Rails.root.join('lib/IMDB-Movie-Data.csv')
csv_options = { col_sep: ',', quote_char: '"', headers: :first_row }

# Movies
CSV.foreach(filepath, csv_options) do |row|
  # Call omdb API for poster
  omdb_url = "http://www.omdbapi.com/?apikey=#{ENV['OMDB_KEY']}&t=#{row['Title']}"
              .unicode_normalize(:nfkd)
                .encode('ASCII', replace: '')
  omdb_api = URI.open(Addressable::URI.parse(omdb_url)).string
  omdb_json = JSON.parse(omdb_api)

  # Create movie object
  p movie = Movie.create!(
    title: row['Title'],
    genre: row['Genre'],
    date_released: row['Year'],
    director: row['Director'],
    description: row['Description'],
    poster_url: omdb_json["Poster"],
    imdb_id: omdb_json["imdbID"],
    rating: row['Rating'].to_i,
  )
end

p iliana = User.create!(
  first_name: 'Iliana',
  last_name: 'Loureiro',
  username: 'iliana009',
  email: 'iliana@gmail.com',
  password: '123456'
)

p aaron = User.create!(
  first_name: 'Aaron',
  last_name: 'Staes',
  username: 'aaron',
  email: 'aaron@gmail.com',
  password: '123456'
)

p hamza = User.create!(
  first_name: 'Hamza',
  last_name: 'ElKholy',
  username: 'hamza',
  email: 'hamza@gmail.com',
  password: '123456'
)

p mert = User.create!(
  first_name: 'Mert',
  last_name: 'Arslan',
  username: 'mert',
  email: 'mert@gmail.com',
  password: '123456'
)
