class CreateEventSpeakers < ActiveRecord::Migration[7.0]
  def change
    create_table :event_speakers do |t|
      t.references :event, type: :string, null: false, foreign_key: true
      t.references :speaker, null: false, foreign_key: true
    end
  end
end
