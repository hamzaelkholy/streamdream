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
Recommendation.destroy_all
Movie.destroy_all
StreamingService.destroy_all
User.destroy_all

puts 'Creating the seeds'

puts 'Creating movies...'

filepath = Rails.root.join('lib/IMDB-Movie-Data.csv')
csv_options = { col_sep: ',', quote_char: '"', headers: :first_row }

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
    date_released: row['Year'].to_i,
    director: row['Director'],
    description: row['Description'],
    poster_url: omdb_json["Poster"],
    imdb_id: omdb_json["imdbID"],
    rating: row['Rating'].to_i
  )
end

CSV.foreach(filepath, csv_options) do |row|
  row['Actors'].split(",").each do |actor|
    p Actor.create(
      name: actor
    )
  end
end

p netflix = StreamingService.create!(
  name: "netflix"
)

p amazonprime = StreamingService.create!(
  name: "amazonprime"
)

p hbo = StreamingService.create!(
  name: "hbo"
)

p hulu = StreamingService.create!(
  name: "hulu"
)

p disney = StreamingService.create!(
  name: "disney"
)

streaming_services = [netflix, amazonprime, hbo, hulu, disney]

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

p mert_r = Recommendation.create!(user: mert, streaming_service: streaming_services.sample)
p hamza_r = Recommendation.create!(user: hamza, streaming_service: streaming_services.sample)
p aaron_r = Recommendation.create!(user: aaron, streaming_service: streaming_services.sample)
p iliana_r = Recommendation.create!(user: iliana, streaming_service: streaming_services.sample)

movie_id = Movie.last.id
movie_id2 = movie_id - 100

p RecommendationMovie.create!(movie_id: rand(movie_id2...movie_id), recommendation: mert_r)
p RecommendationMovie.create!(movie_id: rand(movie_id2...movie_id), recommendation: hamza_r)
p RecommendationMovie.create!(movie_id: rand(movie_id2...movie_id), recommendation: aaron_r)
p RecommendationMovie.create!(movie_id: rand(movie_id2...movie_id), recommendation: iliana_r)

p Availability.create!(movie_id: rand(movie_id2...movie_id), streaming_service: streaming_services.sample)
p Availability.create!(movie_id: rand(movie_id2...movie_id), streaming_service: streaming_services.sample)
p Availability.create!(movie_id: rand(movie_id2...movie_id), streaming_service: streaming_services.sample)
p Availability.create!(movie_id: rand(movie_id2...movie_id), streaming_service: streaming_services.sample)

actor_id = Actor.last.id
actor_id2 = actor_id - 50

10.times do
  MovieActor.create!(movie_id: rand(movie_id2...movie_id), actor_id: rand(actor_id2...actor_id))
end
