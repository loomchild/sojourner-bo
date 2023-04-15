class ConferenceUser < ApplicationRecord
  belongs_to :conference
  belongs_to :user
end
