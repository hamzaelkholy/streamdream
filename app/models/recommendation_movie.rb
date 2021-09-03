class RecommendationMovie < ApplicationRecord
  belongs_to :user
  belongs_to :movie
  belongs_to :streaming_service
end
