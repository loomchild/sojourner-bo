def reset_conference(id, name, start_date, end_date)
  Rake::Task['conference:reset'].invoke(id, name, start_date, end_date)
  Rake::Task['conference:reset'].reenable
  Rake::Task['conference:reset'].all_prerequisite_tasks.each(&:reenable)
end

namespace :conference do
  desc "Resets all data"
  task :reset_all do
    Rake::Task['conference:create_users'].invoke

    reset_conference('fosdem-2019', 'FOSDEM 2019', '2019-02-02', '2019-02-03')
    reset_conference('fosdem-2020', 'FOSDEM 2020', '2020-02-01', '2020-02-02')
    reset_conference('fosdem-2021', 'FOSDEM 2021', '2021-02-06', '2021-02-07')
    reset_conference('fosdem-2022', 'FOSDEM 2022', '2022-02-05', '2022-02-06')
    reset_conference('fosdem-2023', 'FOSDEM 2023', '2023-02-04', '2023-02-05')
    reset_conference('fosdem-2024', 'FOSDEM 2024', '2023-02-03', '2023-02-04')
  end

  desc "Resets all conference data"
  task :reset, [:id, :name, :start, :end] => [:delete, :create_events, :create_favourites, :environment]

  desc "Deletes all conference data, including events and favourites"
  task :delete, [:id] => [:environment] do |_task, args|
    puts "Deleting conference #{args.id}"
    Conference.find_by(id: args.id).try(:destroy)
  end

  desc "Populates all conference event data"
  task :create_events, [:id, :name, :start, :end] => [:environment] do |_task, args|
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

    puts "Fetching data"
    data = FirebaseService.new.conference(args.id)

    puts "Creating conference"
    conference = Conference.create!(id: args.id, name: args.name, start_date: args.start, end_date: args.end)

    puts 'Creating events'
    data[:events].each do |event|
      print '.'
      load_event(conference, event)
    end
    puts
  end

  desc "Resets all conference favourite data"
  task :reset_favourites, [:id] => [:delete_favourites, :create_favourites, :environment]

  desc "Deletes all conference user data"
  task :delete_favourites, [:id] => [:environment] do |_task, args|
    puts "Deleting favourites for conference #{args.id}"
    conference = Conference.find_by!(id: args.id)
    conference.conference_users.destroy_all
  end

  desc "Populates all conference favourite data"
  task :create_favourites, [:id] => [:environment] do |_task, args|
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

    puts "Creating favourites for conference #{args.id}"
    conference = Conference.find_by!(id: args.id)

    puts "Fetching favourites"
    favourites = FirebaseService.new.favourites(args.id)

    puts "Populating favourites"
    missing_events = Set.new
    favourites.each do |id, value|
      create_conference_user_with_favourites(conference, id, value[:favourites], missing_events)
    end
  end

  desc "Resets user registration data"
  task :reset_users, [:id] => [:delete_users, :create_users, :environment]

  desc "Deletes user registration data"
  task delete_users: [:environment] do
    puts "Deleting users"
    User.destroy_all
  end

  desc "Creates user registration data"
  task create_users: [:environment] do
    def create_or_update_user(id, data)
      user = User.find_by(id:)

      if user
        user.update!(**data)
      else
        User.create!(id:, **data)
      end
    end

    puts "Creating users"

    puts "Fetching users"
    users = FirebaseService.new.users

    puts "Populating users"
    users.each do |id, data|
      create_or_update_user(id, data)
    end
  end
end
