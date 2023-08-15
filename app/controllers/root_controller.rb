class RootController < ApplicationController
  before_action :set_conferences

  def index
    @usage_data = usage_data
    @breadth_data = breadth_data
    @depth_data = depth_data

    @total_favourite_count = ConferenceUser.active.sum('favourites_count')
    @total_user_count = ConferenceUser.active.distinct.count(:user_id)
    @total_registered_user_count = ConferenceUser.joins(:user).active.where('users.is_registered').distinct.count(:user_id)
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
    user_data = ConferenceUser.active.group(:conference_id).count
    registered_user_data = ConferenceUser.joins(:user).active.where('users.is_registered', true).group(:conference_id).count

    [
      {
        name: "Registered",
        data: @conferences.map { |conference| [conference.name, registered_user_data[conference.id] || 0] }
      },
      {
        name: "Total",
        data: @conferences.map { |conference| [conference.name, user_data[conference.id]] }
      }
    ]
  end

  def depth_data
    favourite_data = ConferenceUser.active.group(:conference_id).sum(:favourites_count)
    user_data = ConferenceUser.active.group(:conference_id).count

    @conferences.map do |conference|
      favourite_count = favourite_data[conference.id]
      user_count = user_data[conference.id] || 0
      [conference.name, user_count.positive? ? (favourite_count.to_f / user_count).round(1) : 0]
    end
  end
end
