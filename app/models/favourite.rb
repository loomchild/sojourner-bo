class Favourite < ApplicationRecord
  belongs_to :conference
  belongs_to :conference_user, counter_cache: true
  belongs_to :event, counter_cache: true
end
