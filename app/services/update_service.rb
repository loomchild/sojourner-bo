def load_track(conference, track_name)
  track_name = 'Main Tracks' if track_name.start_with?('Main Track')
  conference.tracks.find_by(name: track_name) || conference.tracks.create!(name: track_name)
end

def load_speaker(conference, event, speaker_name)
  speaker = conference.speakers.find_by(name: speaker_name) || conference.speakers.create!(name: speaker_name)
  event.speakers.push(speaker)
end

def load_event(conference, data)
  track = load_track(conference, data[:track])
  type = EventType.find(data[:type])

  event = conference.events.create!(
    id: data[:id],
    track:,
    type:,
    title: data[:title],
    subtitle: data[:subtitle],
    abstract: data[:abstract],
    description: data[:description]
  )

  data[:persons].each { |person| load_speaker(conference, event, person) }
end

def create_conference_user(conference, id)
  conference.conference_users.create!(user_id: id)
end

def create_favourite(conference, conference_user, event_id, created_at)
  conference_user.favourites.create!(conference:, event_id:, created_at:)
end

def create_conference_user_with_favourites(conference, id, favourites_data, missing_events)
  conference_user = create_conference_user(conference, id)

  favourites_data.each do |event_id, data|
    next if missing_events.include?(event_id)

    begin
      create_favourite(conference, conference_user, event_id, data[:updated_at] || '2023-12-31T00:00:00Z')
    rescue ActiveRecord::RecordInvalid => e
      missing_events << event_id
      puts "Skipping favourite for event #{event_id}. #{e}."
    end
  end
end

def create_or_update_user(id, data)
  user = User.find_by(id:)

  if user
    user.update!(**data)
  else
    User.create!(id:, **data)
  end
end

class UpdateService
  def reset_all
    create_users

    reset_conference('fosdem-2019', 'FOSDEM 2019', '2019-02-02', '2019-02-03')
    reset_conference('fosdem-2020', 'FOSDEM 2020', '2020-02-01', '2020-02-02')
    reset_conference('fosdem-2021', 'FOSDEM 2021', '2021-02-06', '2021-02-07')
    reset_conference('fosdem-2022', 'FOSDEM 2022', '2022-02-05', '2022-02-06')
    reset_conference('fosdem-2023', 'FOSDEM 2023', '2023-02-04', '2023-02-05')
    reset_conference('fosdem-2024', 'FOSDEM 2024', '2023-02-03', '2023-02-04')
  end

  def reset_last
    create_users

    reset_conference('fosdem-2024', 'FOSDEM 2024', '2023-02-03', '2023-02-04')
  end

  def reset_conference(id, name, start_date, end_date)
    delete_conference(id)
    create_conference(id, name, start_date, end_date)
  end

  def delete_conference(id)
    Conference.find_by(id:).try(:destroy)
  end

  def create_conference(id, name, start_date, end_date)
    data = FirebaseService.new.conference(id)

    conference = Conference.create!(id: id, name:, start_date:, end_date:)

    data[:events].each do |event|
      load_event(conference, event)
    end

    favourites = FirebaseService.new.favourites(id)

    missing_events = Set.new
    favourites.each do |event_id, value|
      create_conference_user_with_favourites(conference, event_id, value[:favourites], missing_events)
    end
  end

  def reset_users
    delete_users
    create_users
  end

  def delete_users
    User.destroy_all
  end

  def create_users
    users = FirebaseService.new.users

    users.each do |id, data|
      create_or_update_user(id, data)
    end
  end
end
