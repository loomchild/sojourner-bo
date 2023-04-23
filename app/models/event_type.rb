class EventType < ActiveHash::Base
  include ActiveHash::Associations

  has_many :events

  self.data = [
    { id: 'keynote', name: 'Keynote' },
    { id: 'maintrack', name: 'Main track' },
    { id: 'devroom', name: 'Developer room' },
    { id: 'lightningtalk', name: 'Lightning Talk' },
    { id: 'other', name: 'Other' }
  ]
end
