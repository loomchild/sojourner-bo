class ConferencesController < ApplicationController
  before_action :set_conferences
  before_action :set_conference, only: [:show, :events]

  INCREASE_SINCE = 30.days.ago

  def show
    @active_user_count = @conference.users.active.count
    @active_user_count_increase = @conference.users.active.where(created_at: INCREASE_SINCE..).count

    @favourite_count = @conference.users.active.sum(:favourites_count).ceil
    @favourite_count_increase = 0  # TODO: need to add dates to favorites first

    @favourite_count_average = @active_user_count.positive? ? (@favourite_count.to_f / @active_user_count) : 0

    @event_count = @conference.events.count
    @event_favourite_count_average = @event_count.positive? ? (@favourite_count.to_f / @event_count) : 0

    @favourite_histogram_data = favourite_histogram_data

    @events_histogram_data = events_histogram_data
  end

  def events
    @events = @conference.events.popular.includes(:speakers).page(params[:page]).per(10)

    @query = params[:query]
    @events = @events.where('content_searchable @@ websearch_to_tsquery(?)', @query) if @query.present?
  end

  private

  def set_conference
    @conference = Conference.find(params[:conference_id])
  end

  def set_conferences
    @conferences = Conference.by_name
  end

  def favourite_histogram_data
    data = @conference.users.active.group(:favourites_count).count
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
