class User < ApplicationRecord
  has_many :conferece_users
  has_many :conferences, through: :conferece_users
  has_many :favourites
end
