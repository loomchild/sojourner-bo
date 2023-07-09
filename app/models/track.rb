class Track < ApplicationRecord
  belongs_to :conference
  has_many :events

  def favourites_count
    events.map(&:favourites_count).sum
  end
end
