class ConferenceUser < ApplicationRecord
  belongs_to :conference
  belongs_to :user
  has_many :favourites
  has_many :events, through: :favourites
end
