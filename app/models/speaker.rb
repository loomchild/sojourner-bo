class Speaker < ApplicationRecord
  belongs_to :conference
  has_many :event_speakers
  has_many :events, through: :event_speakers
end
