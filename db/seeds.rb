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

csv_text = open('https://github.com/peetck/IMDB-Top1000-Movies/blob/master/IMDB-Movie-Data.csv')

csv = CSV.parse(csv_text, headers: :first_row, liberal_parsing: true)

10.times do
  csv.each do |row|
    movie = Movie.create!(
      title: row['Title'],
      genre: row['Genre'],
      date_released: row['Year'],
      director: row['Director'],
      description: row['Description'],
      rating: row['Rating'].to_i
    )
  end
end
50.times do
  actor = Actor.create!(
    name: Faker::Name.name
  )
end

netflix = StreamingService.create!(
  name: "netflix"
)

amazonprime = StreamingService.create!(
  name: "amazonprime"
)

hbo = StreamingService.create!(
  name: "hbo"
)

hulu = StreamingService.create!(
  name: "hulu"
)

disney = StreamingService.create!(
  name: "disney"
)

streaming_services = [netflix, amazonprime, hbo, hulu, disney]

iliana = User.create!(
  first_name: 'Iliana',
  last_name: 'Loureiro',
  username: 'iliana009',
  email: 'iliana@gmail.com',
  password: '123456'
)

aaron = User.create!(
  first_name: 'Aaron',
  last_name: 'Staes',
  username: 'aaron',
  email: 'aaron@gmail.com',
  password: '123456'
)

  hamza = User.create!(
  first_name: 'Hamza',
  last_name: 'ElKholy',
  username: 'hamza',
  email: 'hamza@gmail.com',
  password: '123456'
)

  mert = User.create!(
  first_name: 'Mert',
  last_name: 'Arslan',
  username: 'mert',
  email: 'mert@gmail.com',
  password: '123456'
)

  mert_r = Recommendation.create!(user: mert, streaming_service: streaming_services.sample)
  hamza_r = Recommendation.create!(user: hamza, streaming_service: streaming_services.sample)
  aaron_r = Recommendation.create!(user: aaron, streaming_service: streaming_services.sample)
  iliana_r = Recommendation.create!(user: iliana, streaming_service: streaming_services.sample)

  movie_id = Movie.last.id
  movie_id2 = movie_id-100

  RecommendationMovie.create!(movie_id: rand(movie_id2...movie_id), recommendation: mert_r)
  RecommendationMovie.create!(movie_id: rand(movie_id2...movie_id), recommendation: hamza_r)
  RecommendationMovie.create!(movie_id: rand(movie_id2...movie_id), recommendation: aaron_r)
  RecommendationMovie.create!(movie_id: rand(movie_id2...movie_id), recommendation: iliana_r)

  Availability.create!(movie_id: rand(movie_id2...movie_id), streaming_service: streaming_services.sample)
  Availability.create!(movie_id: rand(movie_id2...movie_id), streaming_service: streaming_services.sample)
  Availability.create!(movie_id: rand(movie_id2...movie_id), streaming_service: streaming_services.sample)
  Availability.create!(movie_id: rand(movie_id2...movie_id), streaming_service: streaming_services.sample)

  actor_id = Actor.last.id
  actor_id2 = actor_id-50

  10.times do
    MovieActor.create!(movie_id: rand(movie_id2...movie_id),
    actor_id: rand(actor_id2...actor_id))
  end
