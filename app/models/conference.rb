class Conference < ApplicationRecord
  scope :by_name, -> { order(name: :desc) }

  has_many :conference_users, dependent: :destroy
  has_many :users, through: :conference_users
  has_many :events, dependent: :destroy
  has_many :tracks, dependent: :destroy
  has_many :speakers, dependent: :destroy

  def self.root
    by_name.first
  end
end
