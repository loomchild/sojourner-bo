namespace :conference do
  desc "Deletes all conference data"
  task :delete, [:id] => [:environment] do |_task, args|
    Conference.find_by(id: args.id).try(:destroy)
  end

  desc "Populates all conference data"
  task :create, [:id, :name] => [:environment] do |_task, args|
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

    data = download(args.id)

    conference = Conference.create!(id: args.id, name: args.name)

    data[:events].each { |event| load_event(conference, event) }
  end

  desc "Resets all conference data"
  task :reset, [:id, :name] => [:delete, :create, :environment]

  desc "Deletes all user data"
  task :delete_users, [:id] => [:environment] do |_task, args|
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

    def create_favourite(conference_user, event_id)
      conference_user.favourites.create!(event_id:)
    rescue => error
      puts "Skipping favourite for event #{event_id}. #{error}."
    end

    def create_conference_user_with_favourites(conference, id, data)
      # Filter only active users.
      # TODO: move this to service or rethink completely using counters.
      # return if event_ids.size < 5

      conference_user = create_conference_user(conference, id, data[:created_at])
      data[:favourites].each { |event_id| create_favourite(conference_user, event_id) }
    end

    conference = Conference.find_by!(id: args.id)

    users = FirebaseFirestoreService.new.users(conference)
    users.each { |id, value| create_conference_user_with_favourites(conference, id, value) }
  end

  desc "Resets all user data"
  task :reset_users, [:id] => [:delete_users, :create_users, :environment]
end
