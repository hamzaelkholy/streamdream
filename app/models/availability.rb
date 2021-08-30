class Availability < ApplicationRecord
  belongs_to :streaming_service
  belongs_to :movie
end
