class AddFavouritesCountToConferenceUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :conference_users, :favourites_count, :bigint, null: false, default: 0
  end
end
