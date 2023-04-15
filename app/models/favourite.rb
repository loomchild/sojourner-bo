class Favourite < ApplicationRecord
  belongs_to :conference_user
  belongs_to :event
end
