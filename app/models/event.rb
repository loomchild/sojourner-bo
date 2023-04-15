class Event < ApplicationRecord
  belongs_to :type
  belongs_to :conferece
  belongs_to :track
end
