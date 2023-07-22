namespace :conference do
  desc "Deletes all conference data"
  task :delete, [:id] => [:environment] do |_task, args|
    puts "Deleting conference #{args.id}"
    Conference.find_by(id: args.id).try(:destroy)
  end

  desc "Populates all conference data"
  task :create, [:id, :name, :start, :end] => [:environment] do |_task, args|
    def download(conference_id)
      content = FirebaseStorageService.new.download("conferences/#{conference_id}.json")
      JSON.parse(content.string, symbolize_names: true)
    end

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

    puts "Creating conference #{args.id}"

    puts "Downloading data"
    data = download(args.id)

    puts "Creating conference"
    conference = Conference.create!(id: args.id, name: args.name, start_date: args.start, end_date: args.end)

    puts 'Creating events'
    data[:events].each do |event|
      print '.'
      load_event(conference, event)
    end
    puts
  end

  desc "Resets all conference data"
  task :reset, [:id, :name, :start, :end] => [:delete, :create, :create_users, :environment]

  desc "Deletes all user data"
  task :delete_users, [:id] => [:environment] do |_task, args|
    puts "Deleting user data for conference #{args.id}"
    conference = Conference.find_by!(id: args.id)
    conference.conference_users.destroy_all
  end

  desc "Populates all user data"
  task :create_users, [:id] => [:environment] do |_task, args|
    def create_user(id, created_at)
      User.find_by(id:) || User.create!(id:, created_at:)
    end

    def create_conference_user(conference, id, created_at)
      user = create_user(id, created_at)
      conference.conference_users.create(user:)
    end

    def create_favourite(conference, conference_user, event_id)
      conference_user.favourites.create!(conference:, event_id:)
    end

    def create_conference_user_with_favourites(conference, id, data, missing_events)
      conference_user = create_conference_user(conference, id, data[:created_at])

      data[:favourites].each do |event_id|
        next if missing_events.include?(event_id)

        begin
          create_favourite(conference, conference_user, event_id)
        rescue ActiveRecord::RecordInvalid => e
          missing_events << event_id
          puts "Skipping favourite for event #{event_id}. #{e}."
        end
      end
    end

    puts "Creating user data for conference #{args.id}"

    conference = Conference.find_by!(id: args.id)

    puts "Fetching user data"
    users = FirebaseFirestoreService.new.users(conference)

    puts "Populating user data"
    missing_events = Set.new
    users.each { |id, value| create_conference_user_with_favourites(conference, id, value, missing_events) }
  end

  desc "Resets all user data"
  task :reset_users, [:id] => [:delete_users, :create_users, :environment]
end
