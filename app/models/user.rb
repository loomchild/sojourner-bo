class User < ApplicationRecord
  has_many :conferece_users
  has_many :conferences, through: :conferece_users
end
