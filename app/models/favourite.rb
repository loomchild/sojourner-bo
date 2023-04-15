class Favourite < ApplicationRecord
  belongs_to :conference
  belongs_to :user
  belongs_to :event
end
