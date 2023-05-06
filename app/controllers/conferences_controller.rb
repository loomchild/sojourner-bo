class ConferencesController < ApplicationController
  before_action :set_conferences
  before_action :set_conference, only: [:show, :events]

  def show
  end

  def events
    @events = @conference.events.popular.page(params[:page]).per(10)

    @query = params[:query]
    keywords = @query&.split
    keywords&.each do |keyword|
      @events = @events.where('content ILIKE ?', "%#{keyword}%")
    end

    @events
  end

  private

  def set_conference
    @conference = Conference.find(params[:conference_id])
  end

  def set_conferences
    @conferences = Conference.by_name
  end
end
