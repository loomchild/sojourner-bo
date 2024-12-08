def load_track(conference, track_name)
  track_name = 'Main Tracks' if track_name.start_with?('Main Track')
  conference.tracks.find_or_create_by!(name: track_name)
end

def load_speaker(conference, speaker_name)
  conference.speakers.find_or_create_by!(name: speaker_name)
end

def delete_other_events(conference, event_ids)
  conference.events.where.not(id: event_ids).destroy_all
end

def load_event(conference, data)
  track = load_track(conference, data[:track])
  type = EventType.find(data[:type])

  event = conference.events.find_or_create_by(id: data[:id])

  meta = {
    video: !(data[:videos]&.empty?)
  }

  event.update!(
    track:,
    type:,
    title: data[:title],
    subtitle: data[:subtitle],
    abstract: data[:abstract],
    description: data[:description],
    date: data[:date],
    meta:
  )

  speakers = data[:persons].map { |person| load_speaker(conference, person) }

  event.speakers = speakers if speakers != event.speakers
end

def create_conference_user(conference, id, created_at)
  conference_user = conference.conference_users.find_or_create_by!(user_id: id)

  created_at = conference_user.user.created_at if created_at.nil?

  conference_user.update!(created_at:)
  conference_user
end

def create_favourite(conference, conference_user, event_id, created_at)
  favourite = conference_user.favourites.find_or_create_by(conference:, event_id:)
  favourite.update!(created_at:)
end

def create_conference_user_with_favourites(conference, id, favourites_data, missing_events)
  created_at = favourites_data.values.pluck(:updated_at).compact.min

  conference_user = create_conference_user(conference, id, created_at)

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
  user = User.find_or_create_by(id:)
  user.update!(**data)
end

class UpdateService
  def update_all
    update_users

    update_conference('fosdem-2019', 'FOSDEM 2019', '2019-02-02', '2019-02-03')
    update_conference('fosdem-2020', 'FOSDEM 2020', '2020-02-01', '2020-02-02')
    update_conference('fosdem-2021', 'FOSDEM 2021', '2021-02-06', '2021-02-07')
    update_conference('fosdem-2022', 'FOSDEM 2022', '2022-02-05', '2022-02-06')
    update_conference('fosdem-2023', 'FOSDEM 2023', '2023-02-04', '2023-02-05')
    update_conference('fosdem-2024', 'FOSDEM 2024', '2024-02-03', '2024-02-04')
    update_conference('fosdem-2025', 'FOSDEM 2025', '2025-02-01', '2025-02-02')
  end

  def update_last
    update_users

    update_conference_data(Conferenct.latest)
  end

  def reset_conference(id, name, start_date, end_date)
    delete_conference(id)
    update_conference(id, name, start_date, end_date)
  end

  def delete_conference(id)
    Conference.find_by(id:).try(:destroy)
  end

  def update_conference(id, name, start_date, end_date)
    conference = Conference.create_or_find_by(id:)
    conference.update!(name:, start_date:, end_date:)
    conference.touch

    update_conference_data(conference)
  end

  def update_conference_data(conference)
    schedule = ScheduleService.new.get_schedule(conference_id)

    delete_other_events(conference, schedule[:events].map { |event| event[:id] })

    schedule[:events].each do |event|
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
    update_users
  end

  def delete_users
    User.destroy_all
  end

  def update_users
    users = FirebaseService.new.users

    users.each do |id, data|
      create_or_update_user(id, data)
    end
  end
end
