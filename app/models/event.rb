class Event < ApplicationRecord
  belongs_to :type
  belongs_to :conferece
  belongs_to :track
  has_many :event_speakers
  has_many :speakers, through: :event_speakers
  has_many :favourites
  has_many :conferece_users, through: :favourites
  has_many :users, through: :conferece_users
end
