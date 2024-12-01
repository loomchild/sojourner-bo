class Conference < ApplicationRecord
  has_many :conference_users, dependent: :destroy
  has_many :users, through: :conference_users do
    def active
      merge(ConferenceUser.active)
    end
  end
  has_many :favourites, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :tracks, dependent: :destroy
  has_many :speakers, dependent: :destroy

  scope :by_latest, -> { order(name: :desc) }
  scope :latest, -> { by_latest.first }

  def self.root
    latest
  end

  def year
    start_date.year
  end
end
