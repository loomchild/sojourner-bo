class Conference < ApplicationRecord
  has_many :conferece_users
  has_many :users, through: :conferece_users
end
