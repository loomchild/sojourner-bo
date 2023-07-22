class RootController < ApplicationController
  before_action :set_conferences

  def index
    @usage_data = usage_data
    @breadth_data = breadth_data
    @depth_data = depth_data
  end

  private

  def set_conferences
    @conferences = Conference.by_name.reverse
  end

  def usage_data
    data = ConferenceUser.active.group(:conference_id).sum(:favourites_count)

    @conferences.map { |conference| [conference.name, data[conference.id]] }
  end

  def breadth_data
    data = ConferenceUser.active.group(:conference_id).count

    @conferences.map { |conference| [conference.name, data[conference.id]] }
  end

  def depth_data
    favourite_data = ConferenceUser.active.group(:conference_id).sum(:favourites_count)
    user_data = ConferenceUser.active.group(:conference_id).count

    @conferences.map do |conference|
      favourite_count = favourite_data[conference.id]
      user_count = user_data[conference.id]
      [conference.name, user_count.positive? ? (favourite_count.to_f / user_count).round(1) : 0]
    end
  end
end
