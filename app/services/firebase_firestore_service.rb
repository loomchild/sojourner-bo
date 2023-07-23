require 'google/cloud/firestore'

class FirebaseFirestoreService
  def initialize
    @client = Google::Cloud::Firestore.new
  end

  def users(conference)
    conference_id = conference.id.to_sym
    result = {}

    auth_users = fetch_auth_users

    path = Google::Cloud::Firestore::FieldPath.new(conference_id, :favourites)
    collection = @client.col 'users'
    query = collection.where(path, '!=', [])
    query.get do |user|
      user_id = user.document_id
      digest_user_id = digest_id(user_id)
      auth_user = auth_users[user_id]

      favourites = user.data.dig(conference_id, :favourites)
      result[digest_user_id] = {
        created_at: auth_user.created_at,
        is_registered: auth_user.is_registered,
        activated_at: user.created_at,
        favourites:
      }
    end

    result
  end

  def fetch_auth_users
    result = `python/bin/python3 python/users.py`
    JSON.parse(result).transform_values do |value|
      OpenStruct.new({ created_at: Time.at(value['created_at'] / 1000), is_registered: value['is_registered'] })
    end
  end

  def digest_id(id)
    Digest::SHA256.hexdigest(id)
  end
end
