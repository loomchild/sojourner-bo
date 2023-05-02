class ConferencesController < ApplicationController
  layout 'page'

  before_action :set_conferences
  before_action :set_conference, only: [:show, :events]

  def show
  end

  def events
    @events = @conference.events.popular.page(params[:page]).per(10)
  end

  private

  def set_conference
    @conference = Conference.find(params[:conference_id])
  end

  def set_conferences
    @conferences = Conference.by_name
  end
end
