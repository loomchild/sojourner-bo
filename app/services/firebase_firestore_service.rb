require 'google/cloud/firestore'

class FirebaseFirestoreService
  def initialize
    @client = Google::Cloud::Firestore.new
  end

  def users(conference)
    conference_id = conference.id.to_sym
    result = {}

    path = Google::Cloud::Firestore::FieldPath.new(conference_id, :favourites)
    collection = @client.col 'users'
    query = collection.where(path, '!=', [])
    query.get do |user|
      favourites = user.data.dig(conference_id, :favourites)
      result[user.document_id] = {
        created_at: user.created_at,
        favourites:
      }
    end

    result
  end
end
