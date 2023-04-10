require 'google/cloud/firestore'

class DashboardController < ApplicationController
  def index
    client = Google::Cloud::Firestore.new
    path = Google::Cloud::Firestore::FieldPath.new(:'fosdem-2023', :favourites)
    collection = client.col 'users'
    query = collection.where(path, '!=', []).limit(1)
    query.get do |user|
      @favourites = user.data.dig(:'fosdem-2023', :favourites)
    end
  end
end
