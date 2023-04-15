class CreateTracks < ActiveRecord::Migration[7.0]
  def change
    create_table :tracks do |t|
      t.references :conference, type: :string, null: false, foreign_key: true
      t.string :name
    end
  end
end
