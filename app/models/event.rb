class Event < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :type, class_name: 'EventType'
  belongs_to :conference
  belongs_to :track
  has_many :event_speakers, dependent: :destroy
  has_many :speakers, through: :event_speakers
  has_many :favourites, dependent: :destroy
  has_many :conference_users, through: :favourites
  has_many :users, through: :conference_users

  scope :popular, -> { order(favourites_count: :desc).order(:title) }

  def update_speaker_names
    self.speaker_names = speakers.map(&:name).join(' ')
  end

  def day
    date.strftime("%A")
  end
end
