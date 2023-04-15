class Track < ApplicationRecord
  belongs_to :conferece
  has_many :events
end
