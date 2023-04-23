class AddIndexToSpeakers < ActiveRecord::Migration[7.0]
  def change
    add_index :speakers, [:conference_id, :name], unique: true
  end
end
