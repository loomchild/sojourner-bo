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

  def self.root
    by_latest.first
  end
end
