class Event < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :type, class_name: 'EventType'
  belongs_to :conference
  belongs_to :track
  has_many :event_speakers, dependent: :destroy
  has_many :speakers, through: :event_speakers
  has_many :favourites
  has_many :conference_users, through: :favourites
  has_many :users, through: :conference_users

  scope :popular, -> { includes(:favourites).left_joins(:favourites).group(:id).order('COUNT(favourites.id) DESC').order(:title) }
end
