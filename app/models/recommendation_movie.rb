class RecommendationMovie < ApplicationRecord
  belongs_to :recommendation
  belongs_to :movie
end
