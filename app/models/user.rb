class User < ApplicationRecord
  has_many :conference_users, dependent: :destroy
  has_many :conferences, through: :conference_users
  has_many :favourites

  scope :registered, -> { where(is_registered: true) }
end
