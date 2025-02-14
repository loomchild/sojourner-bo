class ConferencesController < ApplicationController
  before_action :set_conferences
  before_action :set_conference, only: [:show, :events, :tracks]

  def show
    @active_user_count = @conference.conference_users.active.count

    @favourite_count = @conference.users.active.sum(:favourites_count).ceil

    @favourite_count_average = @active_user_count.positive? ? (@favourite_count.to_f / @active_user_count) : 0

    @event_count = @conference.events.count
    @event_favourite_count_average = @event_count.positive? ? (@favourite_count.to_f / @event_count) : 0
    @event_with_favourite_count = @conference.events.where(favourites_count: 1..).count
    @event_favourite_coverage = @event_count.positive? ? 100.0 * @event_with_favourite_count / @event_count : 0
    @event_with_video_count = @conference.events.where("meta->'video' = 'true'").count
    @event_with_video_coverage = @event_count.positive? ? 100.0 * @event_with_video_count / @event_count : 0

    @track_count = @conference.tracks.count
    @track_favourite_count_average = @track_count.positive? ? (@favourite_count.to_f / @track_count) : 0

    @returning_user_data = returning_user_data
    @registered_user_data = registered_user_data

    @timeline_recent = @conference.end_date.end_of_day.future? ? params[:timeline_recent] != 'false' : params[:timeline_recent] == 'true'
    @user_timeline_data = user_timeline_data
    @favourite_timeline_data = favourite_timeline_data

    @favourite_histogram_data = favourite_histogram_data

    @events_histogram_data = events_histogram_data
    @tracks_histogram_data = tracks_histogram_data
  end

  def events
    @events = @conference.events.popular.includes(:speakers).page(params[:page]).per(10)

    @query = params[:query]
    return unless @query.present? && @query.size > 1

    keywords = @query&.downcase&.split
    keywords&.each do |keyword|
      @events = @events.where('content LIKE ?', "%#{keyword}%")
    end
  end

  def tracks
    @tracks = @conference.tracks.includes(:events).sort_by(&:favourites_count).reverse
  end

  private

  def set_conference
    @conference = Conference.find(params[:conference_id])
  end

  def set_conferences
    @conferences = Conference.by_latest
  end

  def returning_user_data
    active_user_count = @conference.conference_users.active.count
    return {} unless active_user_count.positive?

    active_returning_user_count = @conference.conference_users.active.where(
      user_id: ConferenceUser.select(:user_id).where('conference_id < ?', @conference.id)
    ).count
    returning_percent = (100.0 * active_returning_user_count / active_user_count).round(1)

    data = {}
    data["Returning (#{returning_percent}%)"] = active_returning_user_count
    data["New (#{(100 - returning_percent).round(1)})"] = active_user_count - active_returning_user_count

    data
  end

  def registered_user_data
    active_user_count = @conference.users.active.count
    return {} unless active_user_count.positive?

    registered_user_count = @conference.users.active.registered.count
    registered_percent = (100.0 * registered_user_count / active_user_count).round(1)

    data = {}
    data["Registered (#{registered_percent}%)"] = registered_user_count
    data["Anonymous (#{100 - registered_percent}%)"] = active_user_count - registered_user_count

    data
  end

  def timeline_interval
    if @timeline_recent
      [29.days.ago.at_beginning_of_day, Time.now.at_end_of_day]
    else
      [@conference.end_date - 22, @conference.end_date + 7]
    end
  end

  def user_timeline_data
    start_ts, end_ts = timeline_interval

    data = @conference.conference_users.active.where(created_at: start_ts..end_ts).group("DATE(conference_users.created_at, 'localtime')").count

    start_ts.to_date.upto(end_ts.to_date) do |date|
      date = date.iso8601
      data[date] = data[date] || 0
    end

    data.sort
  end

  def favourite_timeline_data
    start_ts, end_ts = timeline_interval

    data = @conference.favourites
      .joins(:conference_user)
      .merge(ConferenceUser.active)
      .where(created_at: start_ts..end_ts)
      .group("DATE(favourites.created_at, 'localtime')").count

    start_ts.to_date.upto(end_ts.to_date) do |date|
      date = date.iso8601
      data[date] = data[date] || 0
    end

    data.sort
  end

  def favourite_histogram_data
    data = @conference.users.active.group(:favourites_count).count
    return {} if data.blank?

    max = ceil_max(data.keys.max, 10)
    data.keys.min.upto(max) { |k| data[k] = 0 if data[k].nil? }
    data
  end

  def tracks_histogram_data
    user_tracks =
      @conference
      .conference_users.active
      .joins(:events)
      .group(:conference_user_id)
      .distinct.count(:track_id)

    data = Hash.new(0)
    user_tracks.each_value { |count| data[count] += 1 }

    max = ceil_max(data.keys.max, 5)
    max.times { |k| data[k] = 0 if data[k].zero? }

    data
  end

  def events_histogram_data
    data = @conference.events.group(:favourites_count).count
    max = ceil_max(data.keys.max, 10)
    max.times { |k| data[k] = 0 if data[k].nil? }
    data
  end

  def ceil_max(value, interval)
    return 0 if value.nil?

    (value / interval.to_f).ceil * interval
  end
end
