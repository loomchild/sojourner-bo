class AddContentVectorToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :speaker_names, :string

    add_column :events,
               :content_searchable,
               :virtual,
               type: :tsvector,
               as: "to_tsvector('english', coalesce(title,'') || ' ' || coalesce(subtitle, '') || ' ' || coalesce(abstract, '') || ' ' || coalesce(description, '') || ' ' || coalesce(speaker_names, ''))",
               stored: true

    add_index :events, :content_searchable, using: :gin, name: 'events_content_searchable_idx'
  end
end
