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

    @track_count = @conference.tracks.count
    @track_favourite_count_average = @track_count.positive? ? (@favourite_count.to_f / @track_count) : 0

    @returning_user_data = returning_user_data
    @registered_user_data = registered_user_data

    @timeline_recent = params[:timeline_recent] == 'true'
    @user_timeline_data = user_timeline_data

    @favourite_histogram_data = favourite_histogram_data

    @events_histogram_data = events_histogram_data
  end

  def events
    @events = @conference.events.popular.includes(:speakers).page(params[:page]).per(10)

    @query = params[:query]
    @events = @events.where('content_searchable @@ websearch_to_tsquery(?)', @query) if @query.present?
  end

  def tracks
    data = @conference.tracks.includes(:events).group(:name).sum(:favourites_count)
    @tracks = data.map { |name, favourites_count| OpenStruct.new({ name:, favourites_count: }) }
                 .sort_by(&:favourites_count).reverse
  end

  private

  def set_conference
    @conference = Conference.find(params[:conference_id])
  end

  def set_conferences
    @conferences = Conference.by_name
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
    registered_user_count = @conference.users.active.registered.count

    data = {}
    data["Registered"] = registered_user_count
    data["Anonymous"] = active_user_count - registered_user_count

    data
  end

  def user_timeline_interval
    if @timeline_recent
      [29.days.ago.at_beginning_of_day, Time.now.at_end_of_day]
    else
      [@conference.end_date - 22, @conference.end_date + 7]
    end
  end

  def user_timeline_data
    start_ts, end_ts = user_timeline_interval

    data = @conference.users.where(created_at: start_ts..end_ts).group("DATE(users.created_at AT TIME ZONE 'CET')").count

    start_ts.to_date.upto(end_ts.to_date) do |date|
      data[date] = data[date] || 0
    end

    data.sort
  end

  def favourite_histogram_data
    data = @conference.users.active.group(:favourites_count).count
    return {} if data.blank?

    max = (data.keys.max / 10.0).ceil * 10
    data.keys.min.upto(max) { |k| data[k] = 0 if data[k].nil? }
    data
  end

  def events_histogram_data
    data = @conference.events.group(:favourites_count).count
    max = (data.keys.max / 10.0).ceil * 10
    max.times { |k| data[k] = 0 if data[k].nil? }
    data
  end
end
