class EventType < ActiveHash::Base
  include ActiveHash::Associations

  has_many :events

  self.data = [
    { id: 'keynote', name: 'Keynote', plural_name: 'Keynotes', stat_name: 'lectures' },
    { id: 'maintrack', name: 'Main track', plural_name: 'Main tracks', stat_name: 'tracks' },
    { id: 'devroom', name: 'Developer room', plural_name: 'Developer rooms', stat_name: 'rooms' },
    { id: 'lightningtalk', name: 'Lightning Talk', plural_name: 'Lightning talks', stat_name: 'talks' },
    { id: 'other', name: 'Other', plural_name: 'Other events', stat_name: 'events' }
  ]
end
