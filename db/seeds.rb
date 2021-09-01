# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'faker'
require 'csv'
require 'open-uri'

csv_options = { col_sep: ',', quote_char: '"', headers: :first_row }

url='https://github.com/peetck/IMDB-Top1000-Movies/blob/master/IMDB-Movie-Data.csv'

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

genres = ["action", "fantasy", "sci-fi", "horror", "romantic comedies", "comedies"]

puts 'Creating 100 fake movies...'

filepath = Rails.root.join('lib/IMDB-Movie-Data.csv')
csv_options = { col_sep: ',', quote_char: '"', headers: :first_row }

CSV.foreach(filepath, csv_options) do |row|
    p row
    p movie = Movie.create!(
      title: row['Title'],
      genre: row['Genre'],
      date_released: row['Year'],
      director: row['Director'],
      description: row['Description'],
      rating: row['Rating'].to_i
    )
  end

# csv_options = { col_sep: ',', quote_char: '"', headers: :first_row }
# filepath    = 'IMDB-Movie-Data.csv'

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
  movie_id2 = movie_id-100

  p RecommendationMovie.create!(movie_id: rand(movie_id2...movie_id), recommendation: mert_r)
  p RecommendationMovie.create!(movie_id: rand(movie_id2...movie_id), recommendation: hamza_r)
  p RecommendationMovie.create!(movie_id: rand(movie_id2...movie_id), recommendation: aaron_r)
  p RecommendationMovie.create!(movie_id: rand(movie_id2...movie_id), recommendation: iliana_r)

  p Availability.create!(movie_id: rand(movie_id2...movie_id), streaming_service: streaming_services.sample)
  p Availability.create!(movie_id: rand(movie_id2...movie_id), streaming_service: streaming_services.sample)
  p Availability.create!(movie_id: rand(movie_id2...movie_id), streaming_service: streaming_services.sample)
  p Availability.create!(movie_id: rand(movie_id2...movie_id), streaming_service: streaming_services.sample)

  actor_id = Actor.last.id
  actor_id2 = actor_id-50

  10.times do
    p MovieActor.create!(movie_id: rand(movie_id2...movie_id),
    actor_id: rand(actor_id2...actor_id))
  end
