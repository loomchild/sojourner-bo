require 'faraday'

class FirebaseService
  def conference(conference_id)
    storage_conn.get("conferences/#{conference_id}.json").body
  end

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
      .deep_transform_keys(&:underscore)
      .deep_symbolize_keys
  end

  private

  def storage_conn
    @storage_conn ||= Faraday.new(url: Rails.application.config.firebase.storage) do |conn|
      conn.response :json, parser_options: { symbolize_names: true }
      conn.use Faraday::Response::RaiseError
    end
  end

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
