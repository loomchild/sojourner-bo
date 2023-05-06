class AddFavouritesCountToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :favourites_count, :bigint, null: false, default: 0
  end
end
