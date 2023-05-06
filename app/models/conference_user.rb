class ConferenceUser < ApplicationRecord
  belongs_to :conference
  belongs_to :user
  has_many :favourites, dependent: :destroy
  has_many :events, through: :favourites

  scope :active, -> { where(favourites_count: 5..) }
end
