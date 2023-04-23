class AddNameIndexToTracks < ActiveRecord::Migration[7.0]
  def change
    add_index :tracks, [:conference_id, :name], unique: true
  end
end
