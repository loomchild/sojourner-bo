require 'faraday'

class FirebaseService
  def users
    functions_conn
      .get("adminUsers")
      .body
      .deep_transform_keys(&:underscore)
      .deep_symbolize_keys
  end

  def favourites(conference_id)
    functions_conn
      .get("adminFavourites", conference: conference_id)
      .body
      .deep_transform_keys { |key| key.include?('-') ? key : key.underscore }
      .deep_symbolize_keys
  end

  private

  def functions_conn
    @functions_conn ||= Faraday.new(
      url: Rails.application.config.firebase.functions,
      headers: { 'Content-Type' => 'application/json' }
    ) do |conn|
      conn.request :json
      conn.response :json
      conn.use Faraday::Response::RaiseError
      conn.request :authorization, 'Bearer', Rails.application.config.firebase.token
    end
  end
end
