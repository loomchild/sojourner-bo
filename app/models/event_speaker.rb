class EventSpeaker < ApplicationRecord
  belongs_to :event
  belongs_to :speaker

  after_commit :update_event_speakers

  def update_event_speakers
    return if event.destroyed?

    event.update_speaker_names
    event.save!
  end
end
