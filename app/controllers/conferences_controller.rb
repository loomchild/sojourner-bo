class ConferencesController < ApplicationController
  before_action :set_conferences
  before_action :set_conference, only: [:show, :events]

  INCREASE_SINCE = 30.days.ago

  def show
    @user_count = @conference.users.count
    @user_count_increase = @conference.users.where(created_at: INCREASE_SINCE..).count

    @active_user_count = @conference.users.active.count
    @active_user_count_increase = @conference.users.active.where(created_at: INCREASE_SINCE..).count

    @favourite_count = @conference.favourites.count
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
end
