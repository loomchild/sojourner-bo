class ScheduleService
  attr_reader :schedule

  def fetch_schedule
    store
  end

  private

  def conference
    @conference ||= Conference.latest
  end

  def schedule
    return @schedule if defined?(@schedule)

    @schedule = nil

    headers = {}
    last_modified = Rails.cache.read('schedule-last-modified')
    headers["If-Modified-Since"] = last_modified if last_modified.present?

    faraday = Faraday.new(headers:) do |faraday|
      faraday.use Faraday::FollowRedirects::Middleware
    end

    response = faraday.get("https://fosdem.org/#{conference.year}/schedule/xml")

    if response.status == 304
      Rails.logger.info 'Schedule not modified, skipping'
      return
    end

    Rails.logger.info 'Updating schedule'
    Rails.cache.write('schedule-last-modified', response.headers['last-modified'])

    xml = response.body

    @schedule = Nokogiri::XML(xml)
  end

  def types
    EventType.all.map do |event_type|
      {
        id: event_type.id,
        name: event_type.plural_name,
        stat_name: event_type.stat_name
      }
    end
  end

  def events
    return @event if defined?(@events)
    @events = []

    schedule.xpath('//day').each do |day|
      day.xpath('room').each do |room|
        room.xpath('event').each do |event|
          @events.push(create_event(event, room, day))
        end
      end
    end

    @events.compact!
    @events.sort_by! { |event| event[:id] }

    @events
  end

  def create_event(event, room, day)
    title = event.at_xpath('title').content
    return nil if title.start_with?('CANCELLED')
    title = title[10..] if title.start_with?('AMENDMENT')

    track = event.at_xpath('track').content
    track = track[..-9] if track.end_with?('devroom')

    type = event_type(event)

    persons = event_persons(event)

    links, videos = event_links(event)

    chat = nil

    {
      id: event[:id],
      guid: event[:guid],
      date: day[:date],
      room: room[:name],
      start_time: event.at_xpath('start').content,
      duration: event.at_xpath('duration').content,
      title:,
      abstract: event.at_xpath('abstract').content,
      type:,
      track:,
      persons:,
      videos:,
      links:,
      chat:
    }
  end

  def event_type(event)
    type = event.at_xpath('type').content

    return type if EventType.find_by(id: type).present?

    'other'
  end

  def event_persons(event)
    event.xpath('persons/person').map { |person| person.content }
  end

  def event_links(event)
    videos = []
    links = []

    event.xpath('links/link').each do |link|
      title = link.content

      if title.start_with?('Video recording')
        url = link[:href]
        type = video_type(url)

        videos.push({ url:, type: }) unless type.nil?
      else
        links.push({ title:, href: link[:href] })
      end
    end

    [links, videos]
  end

  def video_type(url)
    return 'video/mp4' if url.end_with?('.mp4')
    return 'video/webm' if url.end_with?('.webm')
  end

  def store
    return if schedule.nil?

    data = {
      events:,
      types:
    }.deep_transform_keys { |key| key.to_s.camelize(:lower) }

    data = JSON.pretty_generate(data)

    filename = "#{Rails.root}/public/conferences/#{conference.id}.json"

    old_hash = Digest::MD5.file(filename).hexdigest
    new_hash = Digest::MD5.hexdigest(data)

    if old_hash == new_hash
      Rails.logger.info "Schedule content not modified, skipping"
      return
    end

    File.open(filename, 'w') do |file|
      file.write(data)
    end
  end
end
